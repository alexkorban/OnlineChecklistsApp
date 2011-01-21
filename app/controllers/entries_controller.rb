class EntriesController < ApplicationController
  def create
    checklist = Checklist.find(params[:checklist_id])  #current_user.account.checklists.find(params[:checklist_id])
    checklist.entries.create :for => params[:for] #, :user_id => current_user.id
    respond_to { |format|
      format.json { render :json => {}, :status => :ok }
    }
  end
end
