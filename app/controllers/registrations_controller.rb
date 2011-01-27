class RegistrationsController < Devise::RegistrationsController
  layout :registrations_layout

  def index
    logger.info "in registrations::index"
    @users = current_account.users
    respond_to { |format|
      format.json { render :json => @users, :status => :ok}
    }
  end

  # DELETE /users/:id
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
        build_resource
        resource.role = "admin"
        acc.users << resource
        acc.save!
        success = true
      }
    rescue ActiveRecord::RecordInvalid
      flash.now[:error] = "The email address is already in use."
    end
    if success
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      flash.now[:error] ||= "Sign up failed, please try again"
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end

  protected

  def registrations_layout
    action_name == "edit" ? "checklists" : nil
  end

end
