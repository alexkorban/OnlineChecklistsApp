class ChecklistsController < ApplicationController
  def index
    @checklists = Checklist.all # current_user.account.checklists.all
    respond_to { |format|
      format.json { render :json => @checklists }
      format.html { render "index" }
    }
  end
end
