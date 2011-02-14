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

  def get_plan
    plan = case current_account.plan
      when "basic" then {users: 5, checklists: 20}
      when "professional" then {users: 15, checklists: 60}
      when "premier" then {users: 50, checklists: 200}
      else raise "Invalid plan passed to limits()"
    end
    plan[:name] = current_account.plan
    plan
  end
end
