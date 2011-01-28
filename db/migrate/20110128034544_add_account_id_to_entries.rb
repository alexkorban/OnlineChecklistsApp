class AddAccountIdToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :account_id, :integer, :limit => 8
  end

  def self.down
    remove_column :entries, :account_id
  end
end
