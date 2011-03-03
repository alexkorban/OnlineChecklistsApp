root = this

class User extends Backbone.Model
  constructor: ->
    super


  email: ->
    @get "email"


  name: ->
    @get "name"


  is_invited: ->
    @get("invitation_token") != null



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


  length: ->
    @items.length


class root.UserListView extends Backbone.View
  id: "user_list"
  tagName: "div"
  events: {
    "click .delete": "on_delete"
    "click .confirm_delete": "on_confirm_delete"
    "click .cancel_delete": "on_cancel_delete"
  }

  constructor: (users) ->
    super

    @template = _.template('''
      <h2>Existing users</h2>
      <div class = "users" style = "width: 60%">
        <% users.each(function(user) { %>
          <div class = "user">
            <h3><%= user.name() ? user.name() : "&lt;no name&gt;" %></h3>
            <%= user.email() %>
            <% if (user.email() != current_user.email) { %>
              <div class = "controls" style = "float:right">
                <a id = "delete_<%= user.cid %>" class = "delete" href = "#">Delete</a>
              </div>
            <% } else { %>
              <br/><br/>This is you. You can't delete yourself. If you need to cancel your subscription, you can do it in the <a href = "/billing">Settings</a>.
            <% } %>
            <% if (user.is_invited()) { %>
              <br/><br/>Invitation sent, waiting for the user to set password.
            <% } %>
          </div>
        <% }); %>
      </div>
      ''')

    $("#" + @id).replaceWith(@el)

    @users = users


  render: =>
    $(@el).html(@template({users: @users}))
    @controls_contents = {}

  on_delete: (e) ->
    cid = e.target.id.substr(7)
    controls = @$(e.target).closest(".controls")
    @controls_contents[cid] = controls.html()
    controls.html("""
      <b>Delete user?</b>
      <a class = 'confirm_delete' id = 'confirm_delete_#{cid}' href = '#'>Delete</a> or
      <a class = 'cancel_delete' id = 'cancel_delete_#{cid}' href = '#'>Cancel</a>
      """)
    e.preventDefault()


  on_confirm_delete: (e) ->
    e.target.id.match("^confirm_delete_(.+)")
    user = @users.getByCid(RegExp.$1)
    user.destroy()
    @users.remove(user)
    e.preventDefault()


  on_cancel_delete: (e) ->
    controls = @$(e.target).closest(".controls")
    controls.html(@controls_contents[e.target.id.substr(14)])
    e.preventDefault()
    e.stopPropagation()



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
      <input type = "hidden" value = "<%= item.cid %>" />
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

    message = """
          You've reached the limits of your plan with <%= window.Plan.users %> users.
          <a href = "/billing">Please consider upgrading to a larger plan</a>.
        """

    @template = _.template("""
      <h2>Invite users</h2>
      <div class = "message" id = "submit_errors" style = "display:none"></div>
      <% if (Users.length >= Plan.users) { %>
        <div class = "message">#{message}</div>
      <% } else { %>
        <div id = "invitation_items" style = "margin-bottom: 20px"></div>
        <div class = "message" style = "margin-bottom: 20px; display: none">
          You cannot invite more than #{Plan.users - Users.length} users on your current plan.<br/>
          <a href = "/billing">Please consider upgrading to a larger plan</a> if you need more users.
        </div>

        <a class = "button add_item" href = "#">Add another invitation</a>
        <br/><br/><br/>
        <a class = "button save" href = "#">Send invitations</a>
      <% } %>
      """)

    @error_template = _.template """
      Please correct the following errors:<br/>
      <% console.log("errors: ", errors); %>
      <ul>
      <% _.each(errors, function(error) { %>
        <% console.log("error: ", error); %>
        <li><%= error %></li>
      <% }); %>
      </ul>
    """

  render: ->
    $(@el).html(@template())
    @item_el = $("#invitation_items")
    @invitations = new InvitationSet
    @invitations.bind "add", @add_item
    @invitations.bind "remove", @remove_item
    @invitations.add(new Invitation)


  add_item: (item) =>
    view = new InvitationItemView {model: item, collection: @invitations}
    item.view = view
    @item_el.append view.render()


  remove_item: (item) =>
    item.view.remove()


  on_add_item: (e) ->
    if Users.length + @invitations.length() >= Plan.users
      @$(".message").show()
    else
      @invitations.add()
    e.preventDefault()


  on_save: (e) ->
    @invitations.save({},
    {
      success: (model, response) =>
        @users.refresh(response)
      error: (model, xhr) =>
        console.log xhr
        @$("#submit_errors").html(@error_template({errors: $.parseJSON(xhr.responseText)})).show()

    })
    e.preventDefault()

#    for invitation in @invitations.models
#      invitation.save() if invitation.email().length > 0


class root.UserPageView extends Backbone.View
  tagName: "div"
  id: "content"
  #events: {"click .back": history.back(1)}

  constructor: (args) ->
    super
    @template = _.template('''
      <div id = "buttons">
        <a class = "button" href = "#checklists">Go to checklists</a>
        <a class = "button" href = "/billing">Manage subscription</a>
      </div>
      <div id = "invitations"></div>
      <div id = "user_list"></div>
      ''')
    $("#" + @id).replaceWith(@el)
    @users = args.users
    @users.bind("refresh", @render)
    @users.bind("remove", @render)
    @render()

  render: =>
    $(@el).html(@template())
    $("#heading").html("Users")
    @user_list_view = new UserListView(@users)
    @invitation_view = new InvitationView(@users)
    @user_list_view.render()
    @invitation_view.render()
