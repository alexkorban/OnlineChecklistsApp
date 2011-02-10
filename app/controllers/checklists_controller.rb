class ChecklistsController < ApplicationController
  # this action serves a dual purpose:
  # - provides a starting point for the whole application in response to an HTML request
  # - returns a list of checklists in response to a JSON request
  def index
    @checklists = current_account.checklists.order("name")
    @users = current_account.users.order("name")

    respond_to { |format|
      format.json { render :json => @checklists }
      format.html { render "index" }
    }
  end

  def show
    checklist = current_account.checklists.find(params[:id])
    respond_to { |format|
      format.json { render :json => checklist.items.order("id") }
    }
  end

  def create
    checklist = current_account.checklists.create(:name => params[:name])
    params[:items].each { |item|
      checklist.items.create :content => item[:content]
    }

    respond_to { |format|
      format.json { render :json => checklist, :status => :ok }
    }
  end

  def update
    checklist = current_account.checklists.find(params[:id])
    checklist.name = params[:name]
    checklist.save
    checklist.item_ids = params[:items].map {|item| item[:id]}
    params[:items].each {|item|
      if item[:id]
        existing_item = checklist.items.find(item[:id])
        existing_item.content = item[:content]
        existing_item.save
      else
        checklist.items.create :content => item[:content]
      end
    }


    respond_to { |format|
      format.json { render :json => {}, :status => :ok }
    }
  end

  def destroy
    checklist = current_account.checklists.find(params[:id])
    if checklist.entries.count > 0    # only delete the checklist if it doesn't have any associated entries; otherwise only deactivate
      checklist.active = false
      checklist.save
    else
      checklist.destroy
    end
    respond_to { |format|
      format.json { render :json => {}, :status => :ok }
    }
  end
end
