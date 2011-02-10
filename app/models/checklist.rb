class Checklist < ActiveRecord::Base
  # Defaults
  default_scope where :active => true

  # Relations
  belongs_to :account
  has_many :items, :dependent => :destroy, :autosave => true
  has_many :entries, :dependent => :destroy

  # Validations
  validates :name, presence: true
  validates :account_id, presence: true, numericality: true
end
