class InvitationsController < Devise::InvitationsController
  def create
    errors = []

    params[:invitations].each {|invitation|
      if current_account.users.active.count >= get_plan[:users]   # make sure the number of users doesn't exceed plan limits
        errors << "Plan limit exceeded for users"
        break
      end
      next if !invitation[:email] || invitation[:email].strip.empty?
      self.resource = resource_class.invite!(invitation)
      errors << resource.errors if !resource.errors.empty?
      # TODO: account should really be set when the user record is created
      # but I don't see an easy way to do it without making account_id mass-assignable which would be bad
      resource.account = current_account
      resource.save
      errors << resource.errors if !resource.errors.empty?
    }

    respond_to {|format|
      format.json {errors.empty? ? render(json: current_account.users.active.order("name").to_json(:only => User::JSON_FIELDS)) :
        render(json: {errors: errors.flatten}, status: :not_acceptable)}
    }
  end
end
