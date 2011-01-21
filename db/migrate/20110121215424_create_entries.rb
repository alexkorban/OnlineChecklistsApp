class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.integer :checklist_id, :limit => 8
      t.string :for
      t.integer :user_id, :limit => 8

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
