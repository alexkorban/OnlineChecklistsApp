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
    "dblclick li": "on_doubleclick"
  }
  constructor: ->
    super
    @parent = $("#content")

    # get rid of any leftover unsaved checklists
    Checklists.refresh(Checklists.select (model) -> model.id?)


    @template = _.template('''
      <% if (flash != null) { %>
        <div id = 'flash' class = 'notice'><div><%= flash %></div></div>
      <% } %>
      <ul class = "checklists">
      <% checklists.each(function(checklist) { %>
      <li class = "checklist" id = "<%= checklist.cid %>"><%= checklist.name() %>
        <span class = "controls">
          <a href="#checklists/<%= checklist.cid %>">Fill out</a> |
          <a class = "secondary" href = "#checklists/<%= checklist.cid %>/edit">Edit</a> |
          <a class = "secondary" id = "remove_<%= checklist.cid %>" class = "remove" href = "#">Delete</a>
        </span>
      </li>
      <% }); %>
      </ul>
      <div style = "margin-top: 40px">
        <a class = "button" href = "#create">Create new list</a>
        <a class = "button" href = "#reports">View reports</a>
        <% if (current_user.role == "admin") { %> <a class = "button" href = "#users">Invite users</a> <% } %>
      </div>
      ''')

    @render()


  render: ->
    $(@el).html(@template({checklists : Checklists, flash: window.app.get_flash()}))
    $("#heading").html("Checklists")
    @parent.html("").append(@el)


  on_doubleclick: (e) ->
    console.log e.target.id
    window.location.hash = "#checklists/#{e.target.id}"


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
      For: <input name = "for" type = "text" />
      <ul>
      <% items.each(function(item) { %>
      <li><%= item.content() %></li>
      <% }); %>
      </ul>
      <a href = "#checklists" class = "button complete">Complete!</a>
      ''')

    @model.items.fetch {success: =>
      @render()
    }


  render: ->
    $(@el).html(@template({items : @model.items}))
    $("#heading").html(@model.name())
    @parent.html("").append(@el)


  on_complete: (e) ->
    entry = new Entry({checklist_id: @model.id, for: @$("input[name=for]").val()})
    entry.save()
    window.app.flash = "Completed checklist: #{@model.name()}"


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
  }
  tagName: "div"
  id: "edit"

  constructor: ->
    super

    @parent = $("#content")

    @template = _.template('''
      Checklist: <input type = "text" class = "checklist_name" value = "<%= name %>" /><br/><br/>
      <ul>
      </ul>
      <ul><li><a class = "button add_item" href = "#">Add step</a></li></ul>
      <br/>
      <br/>
      <a class = "button save" href = "#checklists">Save checklist</a>
      <span style = "margin-left: 20px; margin-right: 10px">or</span>  <a href = "#checklists">Cancel</a>
      ''')

    @model.items.bind "add", @add_item
    @model.items.bind "remove", @remove_item
    @model.items.bind "refresh", @add_items

    @render()
    @item_el = $(@el).find("ul:first")

    if @model.id?
      @model.items.fetch()
    else
      @model.items.refresh([new Item, new Item, new Item])


#    @model.items.fetch {success: =>
#      @render()
#    }


  on_save: (e) ->
    @model.set {"name": @$(".checklist_name").val()}

    @model.save({}, success: (model, response) =>
      @model.set_items_url()
      #@model.set {id: response.id}
    )


  on_add_item: (e) ->
    @model.items.add()
    e.preventDefault()
    e.stopPropagation()


  render: ->
    $(@el).html(@template({name: @model.name(), items : @model.items}))
    $("#heading").html("Create checklist")
    $(@parent).html("").append @el


  add_item: (item) =>
    view = new EditItemView {model: item, collection: @model.items}
    item.view = view
    @item_el.append view.render()


  add_items: =>
    @model.items.each(@add_item)


  remove_item: (item) ->
    item.view.remove()

