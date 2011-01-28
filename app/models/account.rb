class Account < ActiveRecord::Base
  has_many :users, :autosave => true
  has_many :checklists, :autosave => true

  validate :plan, :format => /basic|professional|premier/
end
