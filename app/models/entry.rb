class Entry < ActiveRecord::Base
  belongs_to :checklist
  belongs_to :user

  validates :checklist_id, presence : true, numericality: true
  validates :user_id, presence : true, numericality: true
end
