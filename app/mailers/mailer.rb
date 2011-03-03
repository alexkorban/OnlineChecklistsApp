class Mailer < ActionMailer::Base
  default :from => Devise.mailer_sender

  def signup_confirmation(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, subject: "Welcome to OnlineChecklists")
  end
end

