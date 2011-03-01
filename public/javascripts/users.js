(function() {
  var Invitation, InvitationCollection, InvitationSet, User, UserCollection, root;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  root = this;
  User = (function() {
    __extends(User, Backbone.Model);
    function User() {
      User.__super__.constructor.apply(this, arguments);
    }
    User.prototype.email = function() {
      return this.get("email");
    };
    User.prototype.name = function() {
      return this.get("name");
    };
    User.prototype.is_invited = function() {
      return this.get("invitation_token") !== null;
    };
    return User;
  })();
  UserCollection = (function() {
    __extends(UserCollection, Backbone.Collection);
    UserCollection.prototype.model = User;
    UserCollection.prototype.url = "/users";
    function UserCollection() {
      UserCollection.__super__.constructor.apply(this, arguments);
    }
    return UserCollection;
  })();
  root.Users = new UserCollection;
  Invitation = (function() {
    __extends(Invitation, Backbone.Model);
    function Invitation() {
      Invitation.__super__.constructor.apply(this, arguments);
    }
    Invitation.prototype.name = function() {
      return this.get("name");
    };
    Invitation.prototype.email = function() {
      return this.get("email");
    };
    return Invitation;
  })();
  InvitationCollection = (function() {
    __extends(InvitationCollection, Backbone.Collection);
    InvitationCollection.prototype.model = Invitation;
    function InvitationCollection() {
      InvitationCollection.__super__.constructor.apply(this, arguments);
    }
    return InvitationCollection;
  })();
  InvitationSet = (function() {
    __extends(InvitationSet, Backbone.Model);
    InvitationSet.prototype.url = "/users/invitation";
    function InvitationSet() {
      InvitationSet.__super__.constructor.apply(this, arguments);
      this.items = new InvitationCollection;
    }
    InvitationSet.prototype.add = function(item) {
      return this.items.add(item);
    };
    InvitationSet.prototype.bind = function(event, handler) {
      return this.items.bind(event, handler);
    };
    InvitationSet.prototype.save = function() {
      this.set({
        invitations: this.items
      });
      return InvitationSet.__super__.save.apply(this, arguments);
    };
    InvitationSet.prototype.remove = function(item) {
      return this.items.remove(item);
    };
    InvitationSet.prototype.length = function() {
      return this.items.length;
    };
    return InvitationSet;
  })();
  root.UserListView = (function() {
    __extends(UserListView, Backbone.View);
    UserListView.prototype.id = "user_list";
    UserListView.prototype.tagName = "div";
    UserListView.prototype.events = {
      "click .delete": "on_delete",
      "click .confirm_delete": "on_confirm_delete",
      "click .cancel_delete": "on_cancel_delete"
    };
    function UserListView(users) {
      this.render = __bind(this.render, this);;      UserListView.__super__.constructor.apply(this, arguments);
      this.template = _.template('<h2>Existing users</h2>\n<div class = "users" style = "width: 60%">\n  <% users.each(function(user) { %>\n    <div class = "user">\n      <h3><%= user.name() ? user.name() : "&lt;no name&gt;" %></h3>\n      <%= user.email() %>\n      <% if (user.email() != current_user.email) { %>\n        <div class = "controls" style = "float:right">\n          <a id = "delete_<%= user.cid %>" class = "delete" href = "#">Delete</a>\n        </div>\n      <% } else { %>\n        <br/><br/>This is you. You can\'t delete yourself. If you need to cancel your subscription, you can do it in the <a href = "/billing">Settings</a>.\n      <% } %>\n      <% if (user.is_invited()) { %>\n        <br/><br/>Invitation sent, waiting for the user to set password.\n      <% } %>\n    </div>\n  <% }); %>\n</div>');
      $("#" + this.id).replaceWith(this.el);
      this.users = users;
    }
    UserListView.prototype.render = function() {
      $(this.el).html(this.template({
        users: this.users
      }));
      return this.controls_contents = {};
    };
    UserListView.prototype.on_delete = function(e) {
      var cid, controls;
      cid = e.target.id.substr(7);
      controls = this.$(e.target).closest(".controls");
      this.controls_contents[cid] = controls.html();
      controls.html("<b>Delete user?</b>\n<a class = 'confirm_delete' id = 'confirm_delete_" + cid + "' href = '#'>Delete</a> or\n<a class = 'cancel_delete' id = 'cancel_delete_" + cid + "' href = '#'>Cancel</a>");
      return e.preventDefault();
    };
    UserListView.prototype.on_confirm_delete = function(e) {
      var user;
      e.target.id.match("^confirm_delete_(.+)");
      user = this.users.getByCid(RegExp.$1);
      user.destroy();
      this.users.remove(user);
      return e.preventDefault();
    };
    UserListView.prototype.on_cancel_delete = function(e) {
      var controls;
      controls = this.$(e.target).closest(".controls");
      controls.html(this.controls_contents[e.target.id.substr(14)]);
      e.preventDefault();
      return e.stopPropagation();
    };
    return UserListView;
  })();
  root.InvitationItemView = (function() {
    __extends(InvitationItemView, Backbone.View);
    InvitationItemView.prototype.model = Invitation;
    InvitationItemView.prototype.tagName = "div";
    InvitationItemView.prototype.events = {
      "click .remove_item": "on_remove_item",
      "change input[type=text]": "on_change"
    };
    function InvitationItemView() {
      InvitationItemView.__super__.constructor.apply(this, arguments);
      this.template = _.template('Name: <input type = "text" name = "name" value = "" />\nEmail: <input type = "text" name = "email" value = "" /> <a href = "#" class = "remove_item">X</a>');
    }
    InvitationItemView.prototype.render = function() {
      $(this.el).html(this.template({
        item: this.model
      }));
      return $(this.el);
    };
    InvitationItemView.prototype.on_remove_item = function(e) {
      this.collection.remove(this.model);
      e.preventDefault();
      return e.stopPropagation();
    };
    InvitationItemView.prototype.on_change = function(e) {
      var attr;
      attr = {};
      attr[$(e.target).attr("name")] = $(e.target).val();
      return this.model.set(attr);
    };
    return InvitationItemView;
  })();
  root.InvitationView = (function() {
    __extends(InvitationView, Backbone.View);
    InvitationView.prototype.tagName = "div";
    InvitationView.prototype.id = "invitations";
    InvitationView.prototype.events = {
      "click .add_item": "on_add_item",
      "click .save": "on_save"
    };
    function InvitationView(users) {
      this.remove_item = __bind(this.remove_item, this);;
      this.add_item = __bind(this.add_item, this);;      var message;
      InvitationView.__super__.constructor.apply(this, arguments);
      this.users = users;
      $("#" + this.id).replaceWith(this.el);
      message = "You've reached the limits of your plan with <%= window.Plan.users %> users.\n<a href = \"/users/edit#plan\">Please consider upgrading to a larger plan</a>.";
      this.template = _.template("<h2>Invite users</h2>\n<% if (Users.length >= Plan.users) { %>\n  <div class = \"message\">" + message + "</div>\n<% } else { %>\n  <div id = \"invitation_items\" style = \"margin-bottom: 20px\"></div>\n  <div class = \"message\" style = \"margin-bottom: 20px; display: none\">\n    You cannot invite more than " + (Plan.users - Users.length) + " users on your current plan.<br/>\n    <a href = \"/users/edit#plan\">Please consider upgrading to a larger plan</a> if you need more users.\n  </div>\n\n  <a class = \"button add_item\" href = \"#\">Add another invitation</a>\n  <br/><br/><br/>\n  <a class = \"button save\" href = \"#\">Send invitations</a>\n<% } %>");
    }
    InvitationView.prototype.render = function() {
      $(this.el).html(this.template());
      this.item_el = $("#invitation_items");
      this.invitations = new InvitationSet;
      this.invitations.bind("add", this.add_item);
      this.invitations.bind("remove", this.remove_item);
      return this.invitations.add(new Invitation);
    };
    InvitationView.prototype.add_item = function(item) {
      var view;
      view = new InvitationItemView({
        model: item,
        collection: this.invitations
      });
      item.view = view;
      return this.item_el.append(view.render());
    };
    InvitationView.prototype.remove_item = function(item) {
      return item.view.remove();
    };
    InvitationView.prototype.on_add_item = function(e) {
      if (Users.length + this.invitations.length() >= Plan.users) {
        this.$(".message").show();
      } else {
        this.invitations.add();
      }
      return e.preventDefault();
    };
    InvitationView.prototype.on_save = function(e) {
      this.invitations.save({}, {
        success: __bind(function(model, response) {
          return this.users.refresh(response);
        }, this)
      });
      return e.preventDefault();
    };
    return InvitationView;
  })();
  root.UserPageView = (function() {
    __extends(UserPageView, Backbone.View);
    UserPageView.prototype.tagName = "div";
    UserPageView.prototype.id = "content";
    function UserPageView(args) {
      this.render = __bind(this.render, this);;      UserPageView.__super__.constructor.apply(this, arguments);
      this.template = _.template('<div id = "buttons">\n  <a class = "button" href = "#checklists">Go to checklists</a>\n  <a class = "button" href = "/billing">Manage subscription</a>\n</div>\n<div id = "invitations"></div>\n<div id = "user_list"></div>');
      $("#" + this.id).replaceWith(this.el);
      this.users = args.users;
      this.users.bind("refresh", this.render);
      this.users.bind("remove", this.render);
      this.render();
    }
    UserPageView.prototype.render = function() {
      $(this.el).html(this.template());
      $("#heading").html("Users");
      this.user_list_view = new UserListView(this.users);
      this.invitation_view = new InvitationView(this.users);
      this.user_list_view.render();
      return this.invitation_view.render();
    };
    return UserPageView;
  })();
}).call(this);
