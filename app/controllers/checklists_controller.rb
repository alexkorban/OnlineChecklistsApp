class ChecklistsController < ApplicationController
  def index
    @checklists = Checklist.all # current_user.account.checklists.all
    respond_to { |format|
      format.json { render :json => @checklists }
      format.html { render "index" }
    }
  end

  def show
    checklist = Checklist.find(params[:id]) # current_user.account.checklists.find(params[:id])
    respond_to { |format|
      format.json { render :json => checklist.items }
    }
  end

  def create
    logger.info params
    respond_to { |format|
      format.json { render :json => {}, :status => :ok }
    }
  end

  def update
    checklist = Checklist.find(params[:id]) # current_user.account.checklists.find(params[:id])
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

end
