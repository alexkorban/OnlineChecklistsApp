class AddActiveToChecklists < ActiveRecord::Migration
  def self.up
    add_column :checklists, :active, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :checklists, :active
  end
end
