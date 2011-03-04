class AddNotNullConstraints < ActiveRecord::Migration
  def self.up
    change_column :accounts, :active, :boolean, :null => false
    change_column :users, :active, :boolean, :null => false
  end

  def self.down
    change_column :accounts, :active, :boolean, :null => true
    change_column :users, :active, :boolean, :null => true
  end
end
