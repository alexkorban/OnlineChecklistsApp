class CreateChecklists < ActiveRecord::Migration
  def self.up
    create_table :checklists do |t|
      t.string :name
      t.integer :account_id

      t.timestamps
    end

    change_column :checklists, :id, :integer, limit: 8
  end

  def self.down
    drop_table :checklists
  end
end
