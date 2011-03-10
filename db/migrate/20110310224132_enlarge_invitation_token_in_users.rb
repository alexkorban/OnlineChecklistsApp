class EnlargeInvitationTokenInUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :invitation_token, :string, limit: 60
  end

  def self.down
    change_column :users, :invitation_token, :string, limit: 20
  end
end
