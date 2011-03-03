class ChecklistsController < ApplicationController
  # this action serves a dual purpose:
  # - provides a starting point for the whole application in response to an HTML request
  # - returns a list of checklists in response to a JSON request
  #
  # this is the only place where we perform subscription checks because the other controllers and actions don't provide
  # UI access to checklists; therefore it seems good enough
  def index
    return if !check_account_status

    @checklists = current_account.checklists.active.order("name")
    @users = current_account.users.active.order("name")
    @plan = get_plan

    respond_to { |format|
      format.json { render :json => @checklists }
      format.html { render "index" }
    }
  end

  def show
    checklist = current_account.checklists.active.find(params[:id])
    respond_to { |format|
      format.json { render :json => checklist.items.order("id") }
    }
  end

  def create
    errors = []
    checklist = nil
    if current_account.checklists.active.count >= get_plan[:checklists] # make sure the number of checklists doesn't exceed plan limits
      errors << "Plan limit exceeded for checklists"
    else
      checklist = current_account.checklists.create(:name => params[:name])
      params[:items].each { |item|
        checklist.items.create :content => item[:content]
      }
      errors << checklist.errors if !checklist.errors.empty?
    end

    respond_to { |format|
      format.json { checklist ? render(:json => checklist, :status => :ok) : render(:json => {errors: errors.flatten}, :status => :not_acceptable) }
    }
  end

  def update
    checklist = current_account.checklists.active.find(params[:id])
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
    checklist = current_account.checklists.active.find(params[:id])
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

  def time_zone
    if request.post?
      logger.info "Timezone: #{params[:time_zone]}"
      current_account.update_attributes time_zone: params[:time_zone]
    end

    respond_to { |format|
      format.html { request.post? ? render(nothing: true) : render(:partial => "time_zone_select") }
    }
  end
end
