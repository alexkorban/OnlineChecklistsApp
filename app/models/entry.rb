class Entry < ActiveRecord::Base
  belongs_to :checklist

  validates :checklist_id, presence : true, numericality: true

end
