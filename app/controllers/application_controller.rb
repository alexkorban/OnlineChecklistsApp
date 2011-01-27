class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  protected

  def current_account
    current_user.account
  end

end
