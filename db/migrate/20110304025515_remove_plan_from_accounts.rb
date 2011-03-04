class RemovePlanFromAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :plan
  end

  def self.down
    add_column :accounts, :plan, :string
  end
end
