root = this

class User extends Backbone.Model
  constructor: ->
    super


  email: ->
    @get "email"


  name: ->
    @get "email"


class UserCollection extends Backbone.Collection
  model: User
  url: "/users"

  constructor: ->
    super


class Invitation extends Backbone.Model
  constructor: ->
    super


  email: ->
    @get "email"


class InvitationCollection extends Backbone.Collection
  model: Invitation
  url: "/users/invitations"

  constructor: ->
    super


class root.UserListView extends Backbone.View
  tagName: "div"
  id: "user_list"

  constructor: ->
    super

    @template = _.template('''
      <ul>
      <% users.each(function(user) { %>
      <li><a href="#users-<%= user.cid %>"><%= user.name() %></a>
        (<a href = "#users-<%= user.cid %>-edit">Edit</a> | <a id = "remove_<%= user.cid %>" class = "remove" href = "#">X</a>)</li>
      <% }); %>
      </ul>
      ''')

    @users = new UserCollection
    @users.fetch {success: =>
      @render()
    }


  render: ->
    $(@el).html(@template({users: @users}))
    $("#" + @id).replaceWith(@el)


class root.InvitationItemView extends Backbone.View
  model: Invitation
  tagName: "div"
  events: {
    "click .remove_item": "on_remove_item"
    "change input[type=text]": "on_change"
  }

  constructor: ->
    super

    @template = _.template('''
      <input type = "text" value = "<%= item.email() %>" /> <a href = "#" class = "remove_item">X</a>
    ''')


  render: ->
    $(@el).html(@template({item: @model}))
    return $(@el)


  on_remove_item: (e) ->
    @collection.remove(@model)
    e.preventDefault()
    e.stopPropagation()


  on_change: (e) ->
    @model.set {"email": $(e.target).val()}


class root.InvitationView extends Backbone.View
  tagName: "div"
  id: "invitations"
  events: {
    "click .add_item": "on_add_item"
    "click .save": "on_save"
  }

  constructor: ->
    super

    @template = _.template('''
      <h2>Invite users</h2>
      <div id = "invitation_items"></div>
      <a href = "#" class = "add_item">Add item</a>
      <br/>
      <a href = "#checklists" class = "save">Save</a>
      ''')

    @render()

    @invitations = new InvitationCollection
    @invitations.bind "add", @add_item
    @invitations.bind "remove", @remove_item
    @invitations.add(new Invitation)


  render: ->
    $(@el).html(@template())
    $("#" + @id).replaceWith(@el)
    @item_el = $("#invitation_items")


  add_item: (item) =>
    view = new InvitationItemView {model: item, collection: @invitations}
    item.view = view
    @item_el.append view.render()


  remove_item: (item) =>
    item.view.remove()


  on_add_item: (e) ->
    @invitations.add()
    e.preventDefault()
    e.stopPropagation()


  on_save: (e) ->
    for invitation in @invitations.models
      invitation.save() if invitation.email().length > 0


class root.UserPageView extends Backbone.View
  tagName: "div"
  id: "content"

  constructor: ->
    super
    @template = _.template('''
      <h1>Users</h1>
      <div id = "user_list"></div>
      <div id = "invitations"></div>
      ''')
    @render()
    @user_list_view = new UserListView
    @invitation_view = new InvitationView


  render: ->
    $(@el).html(@template({users: @users}))
    $("##{@id}").replaceWith(@el)
