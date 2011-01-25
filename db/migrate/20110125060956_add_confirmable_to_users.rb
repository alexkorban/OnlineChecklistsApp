class AddConfirmableToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.confirmable
    end
  end

  def self.down
    remove_column :users, :confirmation_token
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmed_at
  end
end
