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


app =
  active_page: ->
    $("#content")


  go_back: ->
    $.historyBack()


Backbone.emulateHTTP = true;    # use _method parameter instead of PUT and DELETE HTTP requests

class Item extends Backbone.Model
  defaults: {content: "New item"}

  constructor: ->
    super


  content: ->
    @get "content"


class ItemCollection extends Backbone.Collection
  model: Item

  constructor: ->
    super


class Checklist extends Backbone.Model
  defaults: {name: "New checklist"}
  constructor: ->
    super
    @items = new ItemCollection
    @items.url = "/checklists/#{@id}"
    #@items.bind("refresh", @f)

  name: ->
    @get "name"


  save: ->
    @set {items: @items}
    super


class ChecklistCollection extends Backbone.Collection
  model: Checklist
  url: "/checklists"

  constructor: ->
    super


class Entry extends Backbone.Model
  url: "/entries"

  constructor: (args) ->
    super



#  checklist: (checklist) ->
#    @set {checklist_id: checklist.id}
#
#
#  for: (content) ->
#    @set {for: content}


#  parse: (response) ->
#    console.log("in Checklists.parse")
#    res = _.map response, (attrs, key) ->
#      attrs.checklist
#    console.log(res)
#    res

@Checklists = new ChecklistCollection


class ChecklistListView extends Backbone.View
  events: {
    "click .remove": "on_remove"
  }
  constructor: ->
    super
    @parent = app.active_page()

    @template = _.template('''
      <ul>
      <% checklists.each(function(checklist) { %>
      <li><a href="#checklists-<%= checklist.cid %>"><%= checklist.name() %></a>
        (<a href = "#checklists-<%= checklist.cid %>-edit">Edit</a> | <a id = "remove_<%= checklist.cid %>" class = "remove" href = "#">X</a>)</li>
      <% }); %>
      </ul>
      <a href = "#create">Create new list</a>
      ''')

    @render()


  render: ->
    $(@el).html(@template({checklists : Checklists}))
    @parent.html("").append(@el)


  on_remove: (e) ->
    console.log "cid = ", e.target.id.substr(7)
    checklist = Checklists.getByCid(e.target.id.substr(7))
    checklist.destroy()
    Checklists.remove(checklist)
    @render()
    e.preventDefault()
    e.stopPropagation()




class ChecklistView extends Backbone.View
  events: {
    "click .complete": "on_complete"
  }
  constructor: ->
    super

    @parent = app.active_page()

    @template = _.template('''
      <h1><%= name %></h1>
      For: <input name = "for" type = "text" />
      <ul>
      <% items.each(function(item) { %>
      <li><a href="#items-<%= item.cid %>"><%= item.content() %></a></li>
      <% }); %>
      </ul>
      <button class = "complete">Complete!</button>
      ''')

    @model.items.fetch {success: =>
      @render()
    }


  render: ->
    $(@el).html(@template({name: @model.name(), items : @model.items}))
    @parent.html("").append(@el)


  on_complete: (e) ->
    entry = new Entry({checklist_id: @model.id, for: @$("input[name=for]").val()})
    entry.save()


class EditItemView extends Backbone.View
  model: Item
  tagName: "li"
  events: {
    "click .remove_item": "on_remove_item"
    "change input[type=text]": "on_change"
  }

  constructor: ->
    super
    @template = _.template('''
      <input type = "text" value = "<%= item.content() %>" /> <a href = "#" class = "remove_item">X</a>
    ''')


  render: ->
    $(@el).html(@template({item: @model}))
    return $(@el)


  on_remove_item: (e) ->
    @collection.remove(@model)
    e.preventDefault()
    e.stopPropagation()


  on_change: (e) ->
    @model.set {"content": $(e.target).val()}


class EditChecklistView extends Backbone.View
  events: {
    "click .save": "on_save"
    "click .add_item": "on_add_item"
    "change .checklist_name": "on_change"
  }
  tagName: "div"
  id: "edit"

  constructor: ->
    super

    @parent = app.active_page()

    @template = _.template('''
      <input type = "text" class = "checklist_name" value = "<%= name %>" /><br/><br/>
      <ul>
      </ul>
      <a href = "#" class = "add_item">Add item</a>
      <br/>
      <a href = "#checklists" class = "save">Save</a>
      ''')

    @model.items.bind "add", @add_item
    @model.items.bind "remove", @remove_item
    @model.items.bind "refresh", @add_items

    @render()
    @item_el = $(@el).find("ul")

    if @model.id?
      @model.items.fetch()
    else
      @model.items.refresh([new Item, new Item, new Item])


#    @model.items.fetch {success: =>
#      @render()
#    }


  on_save: (e) ->
    @model.save()


  on_add_item: (e) ->
    @model.items.add()
    e.preventDefault()
    e.stopPropagation()


  render: ->
    $(@el).html(@template({name: @model.name(), items : @model.items}))
    $(@parent).html("").append @el


  add_item: (item) =>
    view = new EditItemView {model: item, collection: @model.items}
    item.view = view
    @item_el.append view.render()


  add_items: =>
    @model.items.each(@add_item)


  remove_item: (item) ->
    item.view.remove()


  on_change: (e) ->
    @model.set {"name": $(e.target).val()}



class AppController extends Backbone.Controller
  routes:
    "checklists-:cid-edit": "edit"
    "checklists-:cid": "show"
    "checklists": "checklists"
    "create": "create"

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


app.appController = new AppController()


#
# Start the app
#

$(document).ready ->
  $.getJSON "/checklists", (data, textStatus, xhr) =>
    Checklists.refresh(data)

    Backbone.history.start()
    app.appController.checklists()

@app = app