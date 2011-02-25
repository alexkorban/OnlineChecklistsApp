class Account < ActiveRecord::Base
  # relations
  has_many :users, :autosave => true, :dependent => :destroy
  has_many :checklists, :autosave => true, :dependent => :destroy
  has_many :entries, :dependent => :destroy

  PLAN_NAMES = ["basic", "professional", "premier"]

  def has_entries
    entries.count > 0
  end

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

  def trial_expired?
    # Spreedly returns time in UTC and our default time zone is UTC
    get_subscriber.on_trial && !get_subscriber.active
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
    current_account.update_attributes(active: false)
    get_subscriber.stop_auto_renew
  end

  def get_plans
    spreedly_plans = Spreedly::SubscriptionPlan.all
    plans = []
    admin = users.find_by_role("admin")
    PLAN_NAMES.each {|plan_name|
      plan = spreedly_plans.detect{|p| p.name =~ /#{plan_name}/i }
      plan_hash = ActiveSupport::JSON.decode(plan.feature_level).symbolize_keys
      plan_hash[:name] = plan.name
      if checklists.count < plan_hash[:checklists] && users.count < plan_hash[:users]
#        plan_hash[:url] = Spreedly::subscribe_url(self.id, plan.id, email: admin.email)
#      else
        plan_hash[:url] = nil
      end
      plans << plan_hash
    }
    plans
  end
end
