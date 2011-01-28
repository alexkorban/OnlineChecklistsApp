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
    "checklists-:cid-edit": "edit"
    "checklists-:cid": "show"
    "checklists": "checklists"
    "": "checklists"
    "create": "create"
    "users": "users"
    "reports": "reports"
    "timeline": "timeline"
    "timeline-:week_offset": "timeline"
    "charts": "charts"

  constructor: ->
    super


  checklists: ->
    @view = new ChecklistListView


  show: (cid) ->
    @view = new ChecklistView { model: Checklists.getByCid(cid) }


  create: ->
    c = new Checklist
    Checklists.add(c)
    @view = new EditChecklistView { model : c }


  edit: (cid) ->
    @view = new EditChecklistView { model : Checklists.getByCid(cid) }


  users: ->
    @view = new UserPageView { users: @users }


  reports: ->
    @view = new ReportPageView


  timeline: (week_offset) ->
    @view = new TimelineView(week_offset, Users, Checklists)


  charts: ->
    @view = new ChartsView(Users, Checklists)


appController = new AppController()


#
# Start the app
#

$(document).ready ->
    #Checklists.fetch()
    #Users.fetch()
    Backbone.history.start()
#  $.getJSON "/checklists", (data, textStatus, xhr) =>
    #appController.checklists()

@app = appController