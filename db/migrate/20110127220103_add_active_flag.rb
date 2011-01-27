class AddActiveFlag < ActiveRecord::Migration
  def self.up
    add_column :accounts, :active, :boolean, :default => true
    add_column :users, :active, :boolean, :default => true
  end

  def self.down
    remove_column :accounts, :active
    remove_column :users, :active
  end
end
