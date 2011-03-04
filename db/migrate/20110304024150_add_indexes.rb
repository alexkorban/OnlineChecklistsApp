class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :accounts, :active

    add_index :checklists, :active
    add_index :checklists, :account_id

    add_index :entries, :account_id
    add_index :entries, :checklist_id
    add_index :entries, :user_id
    add_index :entries, :created_at

    add_index :items, :checklist_id

    add_index :users, :account_id
    add_index :users, :active
  end

  def self.down
    remove_index :accounts, :active

    remove_index :checklists, :active
    remove_index :checklists, :account_id

    remove_index :entries, :account_id
    remove_index :entries, :checklist_id
    remove_index :entries, :user_id
    remove_index :entries, :created_at

    remove_index :items, :checklist_id

    remove_index :users, :account_id
    remove_index :users, :active
  end
end
