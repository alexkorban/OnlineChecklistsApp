class HelpController < ApplicationController
  def support
    return if !request.post?

    DelayedMailer.push(:support_request, [current_user.id, params[:message]])
    flash.now[:message] = "Thanks for contacting us!"
  end
end
