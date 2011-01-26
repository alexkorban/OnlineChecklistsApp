class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|

      t.timestamps
    end

    change_column :accounts, :id, :integer, :limit => 8
  end

  def self.down
    drop_table :accounts
  end
end
