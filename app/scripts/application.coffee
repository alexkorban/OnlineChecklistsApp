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
    @view = new UserPageView


appController = new AppController()


#
# Start the app
#

$(document).ready ->
  $.getJSON "/checklists", (data, textStatus, xhr) =>
    Checklists.refresh(data)

    Backbone.history.start()
    #appController.checklists()

@app = appController