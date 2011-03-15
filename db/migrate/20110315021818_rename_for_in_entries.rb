class RenameForInEntries < ActiveRecord::Migration
  def self.up
    rename_column :entries, :for, :notes
  end

  def self.down
    rename_column :entries, :notes, :for
  end
end

