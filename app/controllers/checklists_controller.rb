class ChecklistsController < ApplicationController
  before_filter :set_cache_buster, except: [:home, :time_zone]

  def home
    return if !check_account_status

    @checklists = current_account.checklists.active.order("name")
    @users = current_account.users.active.order("name")
    @plan = get_plan

    respond_to { |format|
      format.html { render "index" }
    }
  end

  def index
    return if !check_account_status

    @checklists = current_account.checklists.active.order("name")
    respond_to { |format|
      format.json { render :json => @checklists }
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
    checklist.update_attribute :name, params[:name]

    # intersect existing ids with new ids to ensure that an attacker can't grab items from another account's checklist
    checklist.item_ids = checklist.items.map(&:id) & params[:items].map {|item| item[:id]}

    params[:items].each {|item|
      if item[:id]
        existing_item = checklist.items.find(item[:id])
        existing_item.update_attribute(:content, item[:content]) if existing_item
      else
        checklist.items.create content: item[:content]
      end
    }


    respond_to { |format|
      format.json { render :json => {}, :status => :ok }
    }
  end

  def destroy
    checklist = current_account.checklists.active.find(params[:id])
    if checklist.entries.count > 0    # only delete the checklist if it doesn't have any associated entries; otherwise only deactivate
      checklist.update_attribute :active, false
    else
      checklist.destroy
    end
    respond_to { |format|
      format.json { render :json => {}, :status => :ok }
    }
  end

  def time_zone
    if request.post?
      current_account.update_attribute :time_zone, params[:time_zone]
    end

    respond_to { |format|
      format.html { request.post? ? render(nothing: true) : render(partial: "time_zone_select") }
    }
  end

  # this is to prevent session timeout; the client pings the server every few minutes
  def heartbeat
    respond_to { |format|
      format.json { render :json => {}, :status => :ok }
      format.html { redirect_to root_path }
    }
  end
end
