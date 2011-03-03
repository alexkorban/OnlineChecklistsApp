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

  def check_account_status
    user_session[:account_status] = nil
    if current_account.card_expires_before_next_auto_renew?
      user_session[:account_status] = "Your credit card on file will expire before the next payment is due, please enter new credit card details."
    end
    if current_account.in_grace_period?
      user_session[:account_status] = "Your account is unpaid. Please pay before " +
        "#{current_account.get_subscriber.grace_until.to_date.strftime("%A, %d %b %Y")}."
    end
    if !current_account.subscription_active? # this includes cancelled subscriptions, expired trials and grace period running over
      if current_account.on_trial?
        user_session[:account_status] = "Your trial has expired and your account has been disabled, please subscribe to a paid plan."
      else
        user_session[:account_status] = "Your account is unpaid and has been disabled, please subscribe to a paid plan."
      end
      redirect_to billing_path unless request.url == billing_url
      return false
    end
    true
  end

end
