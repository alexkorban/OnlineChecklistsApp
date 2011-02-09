root = this

class User extends Backbone.Model
  constructor: ->
    super


  email: ->
    @get "email"


  name: ->
    @get "name"


  is_current: ->
    @get "is_current"


class UserCollection extends Backbone.Collection
  model: User
  url: "/users"

  constructor: ->
    super


root.Users = new UserCollection


class Invitation extends Backbone.Model
  constructor: ->
    super


  name: ->
    @get "name"


  email: ->
    @get "email"


class InvitationCollection extends Backbone.Collection
  model: Invitation

  constructor: ->
    super


class InvitationSet extends Backbone.Model
  url: "/users/invitation"

  constructor: ->
    super
    @items = new InvitationCollection


  add: (item) ->
    @items.add(item)


  bind: (event, handler) ->
    @items.bind(event, handler)

  save: ->
    @set {invitations: @items}
    super


  remove: (item) ->
    @items.remove(item)


class root.UserListView extends Backbone.View
  id: "user_list"
  tagName: "div"
  events: {
    "click .remove": "on_remove"
  }

  constructor: (users) ->
    super

    @template = _.template('''
      <ul>
      <% users.each(function(user) { %>
      <li><%= user.name() %> (<%= user.email() %>)
        <% if (user.email() != current_user.email) { %>(<a id = "remove_<%= user.cid %>" class = "remove" href = "#">X</a>)<% } %></li>
      <% }); %>
      </ul>
      ''')

    $("#" + @id).replaceWith(@el)

    @users = users
    @render()


  render: =>
    $(@el).html(@template({users: @users}))


  on_remove: (e) ->
    console.log("in on_remove")
    e.target.id.match("^remove_(.+)")
    user = @users.getByCid(RegExp.$1)
    user.destroy()
    @users.remove(user)
    e.preventDefault()



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
      Name: <input type = "text" name = "name" value = "" />
      Email: <input type = "text" name = "email" value = "" /> <a href = "#" class = "remove_item">X</a>
    ''')


  render: ->
    $(@el).html(@template({item: @model}))
    return $(@el)


  on_remove_item: (e) ->
    @collection.remove(@model)
    e.preventDefault()
    e.stopPropagation()


  on_change: (e) ->
    attr = {}
    attr[$(e.target).attr("name")] = $(e.target).val()
    @model.set attr


class root.InvitationView extends Backbone.View
  tagName: "div"
  id: "invitations"
  events: {
    "click .add_item": "on_add_item"
    "click .save": "on_save"
  }

  constructor: (users) ->
    super

    @users = users
    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <h2>Invite users</h2>
      <div id = "invitation_items" style = "margin-bottom: 20px"></div>

      <a class = "button add_item" href = "#">Add another person</a>
      <br/><br/><br/>
      <a class = "button save" href = "#">Send invitations</a>
      ''')

    @render()

    @invitations = new InvitationSet
    @invitations.bind "add", @add_item
    @invitations.bind "remove", @remove_item
    @invitations.add(new Invitation)


  render: ->
    $(@el).html(@template())
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
    @invitations.save({}, {success: (model, response) =>
      console.log("response:", response)
      console.log("users before:", @users)
      @users.refresh(response)
      console.log("users after:", @users)
    })
    e.preventDefault()

#    for invitation in @invitations.models
#      console.log invitation
#      invitation.save() if invitation.email().length > 0


class root.UserPageView extends Backbone.View
  tagName: "div"
  id: "content"

  constructor: ->
    super
    @template = _.template('''
      <div id = "invitations"></div>
      <div id = "user_list"></div>
      ''')
    $("#" + @id).replaceWith(@el)
    @render()
    @users = new UserCollection
    @user_list_view = new UserListView(@users)
    @invitation_view = new InvitationView(@users)
    @users.bind("refresh", @user_list_view.render)
    @users.bind("remove", @user_list_view.render)

  render: ->
    $(@el).html(@template())
    $("#heading").html("Users")
