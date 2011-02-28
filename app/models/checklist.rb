class Checklist < ActiveRecord::Base
  # Relations
  belongs_to :account
  has_many :items, :dependent => :destroy, :autosave => true
  has_many :entries, :dependent => :destroy

  # Validations
  validates :name, presence: true
  validates :account_id, presence: true, numericality: true

  def self.active
    where active: true
  end
end
