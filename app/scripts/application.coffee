root = this


String::starts_with = (str) ->
  this.match("^" + str) == str


String::ends_with = (str) ->
  this.match(str + "$") == str


root.append_fn = (fn, fn_to_append) ->
    if !fn?
    	return fn_to_append
    else
	    return ->
        fn()
        fn_to_append()


app =
  active_page: ->
    $("#content")


  go_back: ->
    $.historyBack()


class Item extends Backbone.Model
  constructor: ->
    super


  content: ->
    @get "content"


class Checklist extends Backbone.Model
  constructor: ->
    super

  name: ->
    @get "name"


class ChecklistCollection extends Backbone.Collection
  model: Checklist
  url: "/checklists"

  constructor: ->
    super


#  parse: (response) ->
#    console.log("in Checklists.parse")
#    res = _.map response, (attrs, key) ->
#      attrs.checklist
#    console.log(res)
#    res

@Checklists = new ChecklistCollection


class ChecklistListView extends Backbone.View
  constructor: ->
    super
    @el = app.active_page()

    @template = _.template('''
      <div>
      <ul>
      <% checklists.each(function(checklist) { %>
      <li><a href="#checklists-<%= checklist.cid %>"><%= checklist.name() %></a></li>
      <% }); %>
      </ul>
      </div>
      ''')

    @render()


  render: ->
    # Render the content
    console.log("rendering checklist list")
    @el.html(@template({checklists : Checklists}))


class ChecklistView extends Backbone.View
  constructor: ->
    super
    @el = app.active_page()

    @template = _.template('''
      <div>
      <ul>
      <% items.each(function(item) { %>
      <li><a href="#items-<%= item.cid %>"><%= item.content() %></a></li>
      <% }); %>
      </ul>
      </div>
      ''')

    @render()


  render: ->
    # Render the content
    console.log("rendering checklist")
    @el.html(@template({items : Items}))

class AppController extends Backbone.Controller
  routes:
    "checklists-:cid-edit" : "edit"
    "checklists-:cid" : "show"
    "checklists" : "checklists"

  constructor: ->
    super
    @views = {}

  checklists: ->
    console.log "in AppController.checklists"
    @views['checklists'] ||= new ChecklistListView

#  show: (cid) ->
#    @views["venues-#{cid}"] ||= new ShowVenueView { model : Venues.getByCid(cid) }
#
#  edit: (cid) ->
#    @views["venues-#{cid}-edit"] ||= new EditVenueView { model : Venues.getByCid(cid) }

app.appController = new AppController()

#
# Start the app
#

$(document).ready ->
  $.getJSON "/checklists", (data, textStatus, xhr) =>
    console.log(data)
    Checklists.refresh(data)
    Checklists.each (checklist) ->
      console.log(JSON.stringify(checklist))

    Backbone.history.start()
    app.appController.checklists()

@app = app