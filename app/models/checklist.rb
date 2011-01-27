class Checklist < ActiveRecord::Base
  belongs_to :account
  has_many :items, :dependent => :destroy, :autosave => true
  has_many :entries

  validates :name, presence: true
  validates :account_id, presence: true, numericality: true
end
