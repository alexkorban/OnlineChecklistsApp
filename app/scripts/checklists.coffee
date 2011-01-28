root = this

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


class root.Checklist extends Backbone.Model
  defaults: {name: "New checklist"}
  constructor: ->
    super
    @items = new ItemCollection
    @set_items_url()
    #@items.bind("refresh", @f)


  name: ->
    @get "name"


  save: ->
    @set {items: @items}
    super


  set_items_url: ->
    @items.url = "/checklists/#{@id}"



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

root.Checklists = new ChecklistCollection


class root.ChecklistListView extends Backbone.View
  events: {
    "click .remove": "on_remove"
  }
  constructor: ->
    super
    @parent = $("#content")

    @template = _.template('''
      <h1>Checklists</h1>
      <ul>
      <% checklists.each(function(checklist) { %>
      <li><a href="#checklists/<%= checklist.cid %>"><%= checklist.name() %></a>
        (<a href = "#checklists/<%= checklist.cid %>/edit">Edit</a> | <a id = "remove_<%= checklist.cid %>" class = "remove" href = "#">X</a>)</li>
      <% }); %>
      </ul>
      <a href = "#create">Create new list</a> <a href = "#reports">View reports</a>
      <% if (current_user.role == "admin") { %> <a href = "#users">Invite users</a> <% } %>
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




class root.ChecklistView extends Backbone.View
  events: {
    "click .complete": "on_complete"
  }
  constructor: ->
    super

    @parent = $("#content")

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


class root.EditItemView extends Backbone.View
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


class root.EditChecklistView extends Backbone.View
  events: {
    "click .save": "on_save"
    "click .add_item": "on_add_item"
    "change .checklist_name": "on_change"
  }
  tagName: "div"
  id: "edit"

  constructor: ->
    super

    @parent = $("#content")

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
    @model.save({}, success: (model, response) =>
      console.log "checklist id after save: ", @model.id
      @model.set_items_url()
      #@model.set {id: response.id}
    )


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
