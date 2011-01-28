class Checklist < ActiveRecord::Base
  # Defaults
  default_scope :order => "id"

  # Relations
  belongs_to :account
  has_many :items, :dependent => :destroy, :autosave => true
  has_many :entries

  # Validations
  validates :name, presence: true
  validates :account_id, presence: true, numericality: true
end
