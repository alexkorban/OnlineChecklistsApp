class InvitationsController < Devise::InvitationsController
  before_filter :set_cache_buster, only: [:create]

  def create
    errors = []

    params[:invitations].each {|invitation|
      if current_account.users.active.count >= get_plan[:users]   # make sure the number of users doesn't exceed plan limits
        errors << "Plan limit exceeded for users"
        break
      end
      next if !invitation[:email] || invitation[:email].strip.empty?
      self.resource = resource_class.invite!(invitation)
      # TODO: account should really be set when the user record is created
      # but I don't see an easy way to do it without making account_id mass-assignable which would be bad
      resource.account = current_account
      resource.save
      if !resource.errors.empty?
        errors << "Email '#{resource.email}' is not valid"
      end
    }

    respond_to {|format|
      format.json {errors.empty? ? render(json: current_account.users.active.order("name").to_json(:only => User::JSON_FIELDS)) :
        render(json: errors.to_json, status: :not_acceptable)}
    }
  end
end
