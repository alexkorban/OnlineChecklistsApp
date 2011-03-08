class ChangeTestInAccounts < ActiveRecord::Migration
  def self.up
    rename_column :accounts, :test, :test_col
  end

  def self.down
    rename_column :accounts, :test_col, :test
  end
end
