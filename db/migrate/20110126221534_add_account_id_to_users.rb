class AddAccountIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :account_id, :integer, :limit => 8
  end

  def self.down
    remove_column :users, :account_id
  end
end
