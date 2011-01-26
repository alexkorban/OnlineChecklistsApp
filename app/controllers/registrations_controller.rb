class RegistrationsController < Devise::RegistrationsController
  def index
    logger.info "in registrations::index"
    @users = User.all
    respond_to { |format|
      format.json { render :json => @users, :status => :ok}
    }
  end
end
