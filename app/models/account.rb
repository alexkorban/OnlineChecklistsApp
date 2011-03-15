class Account < ActiveRecord::Base
  # relations
  has_many :users, :autosave => true, :dependent => :destroy
  has_many :checklists, :autosave => true, :dependent => :destroy
  has_many :entries, :dependent => :destroy

  # to have a bit more flexibility, we have a defined list of plans in the application, and pick out Spreedly plans that
  # this list
  PLAN_NAMES = ["basic", "professional", "premier"]

  def create_subscriber(plan_name)
    plan_name = plan_name.downcase
    plan_name = "trial" if !PLAN_NAMES.include? plan_name
    user = users.find_by_role("admin")

    # we use account.id to identify subscribers, however we use the admin's email and name
    @subscriber = Spreedly::Subscriber.create!(self.id, email: user.email, screen_name: user.safe_name)

    if plan_name == "trial"
      plans = Spreedly::SubscriptionPlan.all
      subscr_plan = plans.detect { |p| p.trial? }
      @subscriber.activate_free_trial(subscr_plan.id)
      @subscriber = nil # force a fresh copy of the subscriber when it's used next (activate_free_trial doesn't update the subscriber object)
    else
      self.plan = plan_name   # this will be used later to provide the appropriate link to the Spreedly page
      save
    end
  end

  def update_subscriber
    user = users.find_by_role("admin")    # there is only one admin so this is ok
    get_subscriber.update(email: user.email, screen_name: user.safe_name)
    @subscriber = nil
  end

  def on_trial?
    get_subscriber.on_trial
  end

  def card_expires_before_next_auto_renew?
    get_subscriber.card_expires_before_next_auto_renew
  end

  def in_grace_period?
    get_subscriber.in_grace_period
  end

  def subscription_active?
    get_subscriber.active
  end

  def get_subscriber
    @subscriber = Spreedly::Subscriber.find(self.id) if !@subscriber
    @subscriber
  end

  def get_plan
    plan_hash = ActiveSupport::JSON.decode(get_subscriber.feature_level).symbolize_keys
    plan_hash[:name] = get_subscriber.subscription_plan_name
    plan_hash
  end

  def deactivate
    get_subscriber.stop_auto_renew
    update_attribute :active, false
  end

  # this is taken from the Spreedly gem and modified to include subsciber token
  def self.subscribe_url(id, plan, options={})
    %w(screen_name email first_name last_name return_url).each do |option|
      options[option.to_sym] &&= URI.escape(options[option.to_sym])
    end

    screen_name = options.delete(:screen_name)
    token = options.delete(:token)

    params = %w(email first_name last_name return_url).select { |e| options[e.to_sym] }.collect { |e| "#{e}=#{options[e.to_sym]}" }.join('&')

    url = "https://spreedly.com/#{Spreedly.site_name}/subscribers/#{id}/#{token ? token + "/" : ""}subscribe/#{plan}"
    url << "/#{screen_name}" if screen_name
    url << '?' << params unless params == ''

    url
  end

  def get_plans
    spreedly_plans = Spreedly::SubscriptionPlan.all
    plans = []
    PLAN_NAMES.each {|plan_name|
      plan = spreedly_plans.detect{|p| p.name =~ /#{plan_name}/i }
      plan_hash = ActiveSupport::JSON.decode(plan.feature_level).symbolize_keys
      plan_hash[:name] = plan.name
      if checklists.active.count <= plan_hash[:checklists] && users.active.count <= plan_hash[:users]
        plan_hash[:url] = Account.subscribe_url(self.id, plan.id, token: get_subscriber.token)
      else
        plan_hash[:url] = nil   # we don't want to allow the user to subscribe to the plan that would result in them going over limits
      end
      plans << plan_hash
    }
    plans
  end
end
