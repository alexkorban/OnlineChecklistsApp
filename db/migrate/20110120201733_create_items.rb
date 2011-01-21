class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :content
      t.integer :checklist_id, :limit => 8

      t.timestamps
    end

    change_column :items, :id, :integer, :limit => 8
  end

  def self.down
    drop_table :items
  end
end
