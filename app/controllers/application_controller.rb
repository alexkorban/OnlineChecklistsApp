class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  SUPPORT_EMAIL = "support@onlinechecklists.com"


  protected

  def current_account
    current_user.account
  end

  def page_name
    @page_name || controller.action_name
  end

end
