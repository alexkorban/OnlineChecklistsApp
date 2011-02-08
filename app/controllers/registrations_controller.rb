class RegistrationsController < Devise::RegistrationsController
  layout :registrations_layout

  def index
    @users = current_account.users.order("name")
    respond_to { |format|
      format.json { render :json => @users, :status => :ok}
    }
  end

  def new
    flash.now[:plan] = params[:plan]
    flash.now[:plan] = "basic" if !["basic", "professional", "premier"].include? flash.now[:plan]
    super
  end

  # DELETE /users/(:id)
  def destroy
    if params[:id]    # deactivating a user
      u = current_account.users.find(params[:id])
      u.active = false
      u.save
      respond_to { |format|
        format.json { render :json => {}, :status => :ok }
      }
    else              # deactivating the account
      current_account.active = false
      current_account.save
      redirect_to destroy_user_session_path
    end
  end

  def create
    success = false

    begin
      Account.transaction {
        acc = Account.new
        acc.plan = params[resource_name][:plan]
        build_resource
        resource.role = "admin"
        acc.users << resource
        acc.save!

        plans = Spreedly::SubscriptionPlan.all
        trial_plan = plans.detect {|plan| plan.trial? && plan.name =~ /^#{acc.plan}/i }
        subscriber = Spreedly::Subscriber.create!(resource.id, email: resource.email, screen_name: resource.name)

        subscriber.activate_free_trial(trial_plan.id)

        success = true
      }
    rescue ActiveRecord::RecordInvalid
      flash.now[:error] = "The email address is already in use, please log into your existing account or use another email address to create a new account."
    rescue
      flash.now[:error] = "Account couldn't be created, sorry about that. Please contact us at #{SUPPORT_EMAIL} and we'll sort it out for you."
      raise
    end
    if success
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      flash.now[:error] ||= "Sign up failed, please try again"
      clean_up_passwords(resource)
      flash.now[:plan] = params[resource_name][:plan]
      render_with_scope :new
    end
  end

  protected

  def registrations_layout
    action_name == "edit" ? "application" : nil
  end

end
