class Account < ActiveRecord::Base
  has_many :users, :autosave => true
  has_many :checklists, :autosave => true
  has_many :entries

  validate :plan, :format => /basic|professional|premier/

  def has_entries
    entries.count > 0
  end
end
