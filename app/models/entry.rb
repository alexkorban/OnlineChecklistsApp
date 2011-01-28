class Entry < ActiveRecord::Base
  default_scope :order => "created_at"

  scope :between_dates, lambda { |from, to| where("created_at >= ? AND created_at <= ?", from.to_s, to.to_s) }

  belongs_to :checklist
  belongs_to :user
  belongs_to :account

  validates :checklist_id, presence: true, numericality: true
  validates :user_id, presence: true, numericality: true

  def user_name
    user.safe_name
  end

  def checklist_name
    checklist.name
  end

  def display_time
    created_at.strftime("%H:%M")
  end

  # entries must be sorted by created_at
  def self.get_json_entries_by_day(entries)
    entries_by_day = entries.group_by { |entry| entry.created_at.to_date }

    # Make group keys dates instead of indexes, and convert entries to JSON
    json_entries_by_day = {}
    entries_by_day.each { |index, entries|
      json_entries_by_day[entries.first.created_at.strftime("%A, %d %b %Y")] = entries.map {|e|
        {for: e.for, checklist_name: e.checklist_name, user_name: e.user_name, display_time: e.display_time}
        }
    }
    json_entries_by_day
  end

end
