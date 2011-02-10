class EntriesController < ApplicationController
  def create
    checklist = current_account.checklists.find(params[:checklist_id])
    checklist.entries.create :for => params[:for], :user_id => current_user.id, :account_id => current_account.id
    respond_to { |format|
      format.json { render json: {}, status: :ok }
    }
  end

  def index
    # if anything is wrong, return current week; note that to_i returns 0 if it failed to convert a string
    week_offset = params[:week_offset] ? params[:week_offset].to_i : 0
    d = Date.today.advance weeks: -week_offset
    from = d.beginning_of_week
    to = d.end_of_week

    entries = current_account.entries.between_dates(from, to).includes(:checklist)#.order("created_at")

    checklist_id = params[:checklist_id] ? params[:checklist_id].to_i : 0
    entries = entries.for_checklist(checklist_id) if checklist_id > 0

    user_id = params[:user_id] ? params[:user_id].to_i : 0
    entries = entries.for_user(user_id) if user_id > 0

    logger.info "Entries:"
    logger.info entries.inspect

    respond_to {|format|
      format.json {
        render json: Entry.get_entries_by_day(entries), status: :ok
      }
    }
  end

  def counts
    checklist_id = params[:checklist_id] ? params[:checklist_id].to_i : 0

    entries = current_account.entries.within_one_year(Date.today)
    entries = entries.for_checklist(checklist_id) if checklist_id > 0

    counts = entries.monthly_counts
    logger.info "COUNTS: ", counts.inspect
    user_ids = current_account.users.select("id").order("id")
    respond_to {|format|
      format.json { render json: {user_ids: user_ids.map(&:id) + [0], counts: Entry.transpose_counts(counts, user_ids)}, status: :ok }
    }
  end
end
