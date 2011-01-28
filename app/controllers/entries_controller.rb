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

    entries = current_account.entries.between_dates(from, to)

    respond_to {|format|
      format.json {
        render json: Entry::get_json_entries_by_day(entries), status: :ok
      }
    }
  end
end
