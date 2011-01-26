class InvitationsController < Devise::InvitationsController
  def create
    self.resource = resource_class.invite!(params)    # our client passes the attributes directly instead of wrapping them in :user

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions
      redirect_to after_update_path_for(resource_name)
    else
      render_with_scope :new
    end
  end
end
