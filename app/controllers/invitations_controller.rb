class InvitationsController < Devise::InvitationsController
  def create
    errors = []

    params[:invitations].each {|invitation|
      self.resource = resource_class.invite!(invitation)
      errors << resource.errors if !resource.errors.empty?
      # TODO: account should really be set when the user record is created
      # but I don't see an easy way to do it without making account_id mass-assignable which would be bad
      resource.account = current_account
      resource.save
      errors << resource.errors if !resource.errors.empty?
    }

    respond_to {|format|
      format.json {errors.empty? ? render(json: current_account.users.all) : render(json: {errors: errors.flatten}, status: :not_acceptable)}
    }
#    self.resource = resource_class.invite!(params)    # our client passes the attributes directly instead of wrapping them in :user
#
#    if resource.errors.empty?
#      set_flash_message :notice, :send_instructions
#      redirect_to after_update_path_for(resource_name)
#    else
#      render_with_scope :new
#    end
  end
end
