class Entry < ActiveRecord::Base
  scope :between_dates, lambda { |from, to| where("created_at >= ? AND created_at <= ?", from.to_s, to.to_s) }
  scope :for_checklist, lambda { |checklist_id| where("checklist_id = ?", checklist_id) }
  scope :for_user, lambda { |user_id| where("user_id = ?", user_id) }
  scope :within_one_year, lambda { |today| where("created_at > ?", today - 1.year)}
  scope :within_one_month, lambda { |today| where("created_at > ?", today - 1.month) }
  scope :monthly_counts, :select => "count(id), extract(month from date_trunc('month', created_at)) as month,
         extract(year from date_trunc('month', created_at)) as year, user_id",  :group => "date_trunc('month', created_at), user_id",
        :order => "date_trunc('month', created_at), user_id"
  scope :daily_counts, :select => "count(id), date_trunc('day', created_at) as date, user_id",
        :group => "date_trunc('day', created_at), user_id",
        :order => "date_trunc('day', created_at), user_id"

#  select extract(month from date_trunc('month', created_at)),
#         extract(year from date_trunc('month', created_at)), count(*) from entries group by date_trunc('month', created_at);

  belongs_to :checklist
  belongs_to :user
  belongs_to :account

  validates :checklist_id, presence: true, numericality: true
  validates :user_id, presence: true, numericality: true

  def user_name
    user.safe_name
  end

  def checklist_name
    if checklist.nil?
      logger.info "Checklist id: #{checklist_id}"
    end
    checklist.name
  end

  def display_time
    created_at.strftime("%H:%M")
  end

  def self.get_entries_by_day(entries)
    entries.group_by {|entry|               # group entries by date - produces a hash of entry arrays with dates as keys

      entry.created_at.to_date

    }.inject({}) {|hash, entries_for_date|

      logger.info "Entries for date"
      logger.info entries_for_date.inspect

      # Format keys (which are dates) for display, and filter out unnecessary attributes from the entries
      # the result is still a hash of entry arrays with formatted dates as keys
      hash[entries_for_date.first.strftime("%A, %d %b %Y")] = entries_for_date.last.map { |e|
        {for: e.for, checklist_name: e.checklist_name, user_name: e.user_name, display_time: e.display_time}
      }; hash

    }
  end

  def self.get_monthly_counts(account, checklist_id)
    entries = account.entries.within_one_year(Date.today)
    entries = entries.for_checklist(checklist_id) if checklist_id > 0

    user_ids = account.users.select("id").order("id")
    counts = entries.monthly_counts

    res = counts.group_by {|row|

      [row.month, row.year]

    }.map {|date, counts|

      user_counts = get_user_counts(counts, user_ids)
      [Date.new(date.last.to_i, date.first.to_i, 1).end_of_month] + user_counts + [counts.inject(0) { |sum, count| sum += count[:count].to_i; sum }]

    }
    # prepend an extra batch of zero counts before the first month; this is to make the chart look nicer
    res.insert(0, [(res[0].first - 1.month).end_of_month] + Array.new(user_ids.size + 1, 0)) if counts.size > 0
    res
  end

  def self.get_daily_counts(account, checklist_id)
    entries = account.entries.within_one_month(Date.today)
    entries = entries.for_checklist(checklist_id) if checklist_id > 0

    user_ids = account.users.select("id").order("id")
    counts = entries.daily_counts

    res = counts.group_by { |row|

      row.date

    }.map { |date, counts|

      user_counts = get_user_counts(counts, user_ids)
      [Date.parse(date)] + user_counts + [counts.inject(0) { |sum, count| sum += count[:count].to_i; sum }]

    }
    # prepend an extra batch of zero counts before the first day; this is to make the chart look nicer
    res.insert(0, [(res[0].first - 1.day)] + Array.new(user_ids.size + 1, 0)) if counts.size > 0
    res
  end

  # produces an array of counts for each user id, inserting zero if there is no count present in input counts
  # users must be sorted by id
  def self.get_user_counts(counts, user_ids)
    counts_by_user_id = counts.inject({}) {|hash, count| hash[count[:user_id]] = count[:count]; hash}
    user_ids.map {|u|
      counts_by_user_id.include?(u.id) ? counts_by_user_id[u.id].to_i : 0
    }
  end
end
