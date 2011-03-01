class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :set_time_zone

  SUPPORT_EMAIL = "support@onlinechecklists.com"


  protected

  def current_account
    current_user.account
  end

  def page_name
    @page_name || controller.action_name
  end

  def get_plan
    current_account.get_plan
  end

  def set_time_zone
    Time.zone = current_account.time_zone if current_user
  end
end
