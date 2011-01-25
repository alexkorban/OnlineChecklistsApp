class Checklist < ActiveRecord::Base
  has_many :items, :dependent => :destroy, :autosave => true
  has_many :entries

  validates :name, presence: true
  validates :account_id, presence: true, numericality: true
end
