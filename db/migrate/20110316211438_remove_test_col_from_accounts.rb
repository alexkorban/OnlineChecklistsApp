class RemoveTestColFromAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :test_col
  end

  def self.down
    add_column  :accounts, :test_col, :string
  end
end
