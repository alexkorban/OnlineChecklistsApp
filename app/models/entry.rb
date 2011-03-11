class Entry < ActiveRecord::Base
  # Relations
  belongs_to :checklist
  belongs_to :user
  belongs_to :account

  # Validations
  validates :checklist_id, presence: true, numericality: true
  validates :user_id, presence: true, numericality: true
  validates :account_id, presence: true, numericality: true

  # Scopes
  scope :for_checklist, lambda { |checklist_id| where("checklist_id = ?", checklist_id) }
  scope :for_user, lambda { |user_id| where("user_id = ?", user_id) }
  scope :within_one_year, lambda { |today| where("created_at > ?", (today - 1.year).end_of_day.utc.to_s) }
  scope :within_one_month, lambda { |today| where("created_at > ?", (today - 1.month).end_of_day.utc.to_s) }

  def self.between_dates(from, to)
    where("created_at >= ? AND created_at <= ?", from.beginning_of_day.utc.to_s, to.end_of_day.utc.to_s)
  end

  def self.grouped_counts(group_by)
    # time_field expression is Postgres specific; it produces a timestamp which is converted from UTC to the current user's time zone,
    # giving us the correct partitioning by the user's day/week/month
    time_field = "created_at at time zone 'UTC' at time zone interval '#{Time.zone.now.formatted_offset}'"
    select("count(id), date_trunc('#{group_by}', #{time_field}) as date, user_id").
      group("date_trunc('#{group_by}', #{time_field}), user_id").
      order("date_trunc('#{group_by}', #{time_field}), user_id")
  end


  def user_name
    user.safe_name
  end

  def checklist_name
    checklist.name
  end

  def display_time
    created_at.strftime("%H:%M")
  end

  def self.get_entries_by_day(entries)
    entries.group_by {|entry|               # group entries by date - produces a hash of entry arrays with dates as keys

      entry.created_at.to_date

    }.inject([]) {|res, entries_for_date|

      # Format keys (which are dates) for display, and filter out unnecessary attributes from the entries
      # the result is still a hash of entry arrays with formatted dates as keys
      res.push([entries_for_date.first, entries_for_date.last.map { |e|
        {for: e.for, checklist_name: e.checklist_name, user_name: e.user_name, display_time: e.display_time}
      }]); res

    }.sort {|a, b|
      a.first <=> b.first
    }.each {|entry|
      entry[0] = entry[0].strftime("%A, %d %b %Y")
    }
  end

  def self.get_counts(account, checklist_id, group_by)
    entries = account.entries.send(group_by == :day ? :within_one_month : :within_one_year, Time.zone.today)
    entries = entries.for_checklist(checklist_id) if checklist_id > 0

    users = account.users.select("id, name, email").order("id")
    db_counts = entries.grouped_counts(group_by.to_s)

    counts = db_counts.group_by { |row|

      row.date

    }.map { |date, counts|

      user_counts = get_user_counts(counts, users)
      [get_end_of_period(group_by, Date.parse(date))] + [counts.inject(0) { |sum, count| sum += count[:count].to_i; sum }] + user_counts

    }
    # prepend an extra batch of zero counts before the first month; this is to make the chart look nicer
    counts.insert(0, [get_end_of_period(group_by, counts[0].first - 1.send(group_by))] + Array.new(users.size + 1, 0)) if counts.size > 0

    checklists = account.checklists.select("id, name").order("name")

    {users: [{id: 0, name: 'All users'}] + users.map { |u| {id: u.id, name: u.safe_name} }, counts: counts, checklists: checklists}
  end

  # produces an array of counts for each user id, inserting zero if there is no count present in input counts
  # users must be sorted by id
  def self.get_user_counts(counts, users)
    counts_by_user_id = counts.inject({}) {|hash, count| hash[count[:user_id]] = count[:count]; hash}
    users.map {|u|
      counts_by_user_id.include?(u.id) ? counts_by_user_id[u.id].to_i : 0
    }
  end

  def self.get_end_of_period(group_by, date)
    case group_by
      when :day then date
      when :week then date.end_of_week
      when :month then date.end_of_month
    end
  end
end
