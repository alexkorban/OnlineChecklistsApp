class AddTestToAccounts < ActiveRecord::Migration
  class Account < ActiveRecord::Base; end

  def self.up
    add_column :accounts, :test, :string, :default => "test_value"
    Account.reset_column_information
    Account.update_all test: "test_value"
  end

  def self.down
    remove_column :accounts, :test
  end
end
