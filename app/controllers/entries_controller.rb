class EntriesController < ApplicationController
  def create
    checklist = current_account.checklists.active.find(params[:checklist_id])
    checklist.entries.create :for => params[:for], :user_id => current_user.id, :account_id => current_account.id
    respond_to { |format|
      format.json { render json: {}, status: :ok }
    }
  end

  def index
    # if anything is wrong, return current week; note that to_i returns 0 if it failed to convert a string
    week_offset = params[:week_offset] ? params[:week_offset].to_i : 0
    d = Time.zone.today.advance weeks: -week_offset
    from = d.beginning_of_week
    to = d.end_of_week

    entries = current_account.entries.between_dates(from, to).includes(:checklist).order("created_at")

    checklist_id = params[:checklist_id] ? params[:checklist_id].to_i : 0
    entries = entries.for_checklist(checklist_id) if checklist_id > 0

    user_id = params[:user_id] ? params[:user_id].to_i : 0
    entries = entries.for_user(user_id) if user_id > 0

    respond_to {|format|
      format.json {
        entries_by_day = Entry.get_entries_by_day(entries)
        # return a 404 to indicate an account without entries so the client can display instructions
        render json: entries_by_day, status: (entries_by_day.empty? && current_account.entries.count == 0) ? :not_found : :ok
      }
    }
  end

  def counts
    checklist_id = params[:checklist_id] ? params[:checklist_id].to_i : 0
    group_by = case params[:group_by]
                 when "day" then :day
                 when "week" then :week
                 else :month
               end

    counts = Entry.get_counts(current_account, checklist_id, group_by)

    respond_to {|format|
      format.json { render json: counts, status: :ok }
    }
  end
end
