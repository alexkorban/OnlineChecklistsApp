root = this


String::starts_with = (str) ->
  this.match("^" + str) == str


String::ends_with = (str) ->
  this.match(str + "$") == str


# add a chainable logging function to jQuery
jQuery.fn.log = (msg) ->
  console.log("%s: %o", msg, this)
  return this


root.append_fn = (fn, fn_to_append) ->
    if !fn?
    	return fn_to_append
    else
	    return ->
        fn()
        fn_to_append()


Backbone.emulateHTTP = true;    # use _method parameter instead of PUT and DELETE HTTP requests



class AppController extends Backbone.Controller
  routes:
    "": "checklists"
    "checklists": "checklists"
    "checklists/:cid/edit": "edit"
    "checklists/:cid": "show"
    "create": "create"
    "users": "users"
    "reports": "reports"
    "timeline": "timeline"
    "timeline/:week_offset/u:user_id/c:checklist_id": "timeline"
    "charts": "charts"
    "charts/u:user_ids/c:checklist_id": "charts"

  constructor: ->
    super
    @flash = null


  get_flash: ->
    s = @flash
    @flash = null
    s

  checklists: ->
    @view = new ChecklistListView


  show: (cid) ->
    @view = new ChecklistView { model: Checklists.getByCid(cid) }


  create: ->
    c = new Checklist
    Checklists.add(c)
    @view = new EditChecklistView { model: c }


  edit: (cid) ->
    @view = new EditChecklistView { model: Checklists.getByCid(cid) }


  users: ->
    @view = new UserPageView { users: @users }


  reports: ->
    @view = new ReportPageView


  timeline: (week_offset, user_id, checklist_id) ->
    @view = new TimelineView({week_offset: week_offset, users: Users, checklists: Checklists, user_id: user_id, checklist_id: checklist_id})


  charts: (user_ids, checklist_id)->
    checklist_id = Checklists.at(0).id if !checklist_id?
    @view = new ChartView({user_ids: user_ids, checklist_id: checklist_id, users: Users, checklists: Checklists})


#
# Start the app
#

$(document).ready ->
  window.app = new AppController()
  Backbone.history.start()


