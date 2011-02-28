class RegistrationsController < Devise::RegistrationsController
  layout :registrations_layout

  def index
    @users = current_account.users.active.order("name") if current_user

    respond_to { |format|
      format.json { render :json => @users.to_json(:only => User::JSON_FIELDS), :status => :ok}
    }
  end

  def new
    flash.now[:plan] = params[:plan]
    flash.now[:plan] = "trial" if !["basic", "professional", "premier"].include? flash.now[:plan]
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
      current_account.deactivate
      flash.now[:alert] = "We are sorry to see you go. If you have any feedback about OnlineChecklists, please write us "
      #redirect_to destroy_user_session_path
      sign_out current_user

    end
  end

  def create
    success = false

    begin
      Account.transaction {
        plan = params[resource_name][:plan]
        acc = Account.new
        build_resource
        resource.role = "admin"
        acc.users << resource
        acc.save!
        logger.info "Res name: #{resource_name}, plan: #{plan}"
        acc.create_subscriber(plan)
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

  def edit
    @plan = get_plan
    @plans = current_account.get_plans
    super
  end

  protected

  def registrations_layout
    ["edit", "new", "destroy"].include?(action_name) ? "application" : nil
  end

end
