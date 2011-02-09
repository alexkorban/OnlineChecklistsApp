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
    User.prototype.is_current = function() {
      return this.get("is_current");
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
    return InvitationSet;
  })();
  root.UserListView = (function() {
    __extends(UserListView, Backbone.View);
    UserListView.prototype.id = "user_list";
    UserListView.prototype.tagName = "div";
    UserListView.prototype.events = {
      "click .remove": "on_remove"
    };
    function UserListView(users) {
      this.render = __bind(this.render, this);;      UserListView.__super__.constructor.apply(this, arguments);
      this.template = _.template('<ul>\n<% users.each(function(user) { %>\n<li><%= user.name() %> (<%= user.email() %>)\n  <% if (user.email() != current_user.email) { %>(<a id = "remove_<%= user.cid %>" class = "remove" href = "#">X</a>)<% } %></li>\n<% }); %>\n</ul>');
      $("#" + this.id).replaceWith(this.el);
      this.users = users;
      this.render();
    }
    UserListView.prototype.render = function() {
      return $(this.el).html(this.template({
        users: this.users
      }));
    };
    UserListView.prototype.on_remove = function(e) {
      var user;
      console.log("in on_remove");
      e.target.id.match("^remove_(.+)");
      user = this.users.getByCid(RegExp.$1);
      user.destroy();
      this.users.remove(user);
      return e.preventDefault();
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
      this.add_item = __bind(this.add_item, this);;      InvitationView.__super__.constructor.apply(this, arguments);
      this.users = users;
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<h2>Invite users</h2>\n<div id = "invitation_items" style = "margin-bottom: 20px"></div>\n\n<a class = "button add_item" href = "#">Add another person</a>\n<br/><br/><br/>\n<a class = "button save" href = "#">Send invitations</a>');
      this.render();
      this.invitations = new InvitationSet;
      this.invitations.bind("add", this.add_item);
      this.invitations.bind("remove", this.remove_item);
      this.invitations.add(new Invitation);
    }
    InvitationView.prototype.render = function() {
      $(this.el).html(this.template());
      return this.item_el = $("#invitation_items");
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
      this.invitations.add();
      e.preventDefault();
      return e.stopPropagation();
    };
    InvitationView.prototype.on_save = function(e) {
      this.invitations.save({}, {
        success: __bind(function(model, response) {
          console.log("response:", response);
          console.log("users before:", this.users);
          this.users.refresh(response);
          return console.log("users after:", this.users);
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
    function UserPageView() {
      UserPageView.__super__.constructor.apply(this, arguments);
      this.template = _.template('<div id = "invitations"></div>\n<div id = "user_list"></div>');
      $("#" + this.id).replaceWith(this.el);
      this.render();
      this.users = new UserCollection;
      this.user_list_view = new UserListView(this.users);
      this.invitation_view = new InvitationView(this.users);
      this.users.bind("refresh", this.user_list_view.render);
      this.users.bind("remove", this.user_list_view.render);
    }
    UserPageView.prototype.render = function() {
      $(this.el).html(this.template());
      return $("#heading").html("Users");
    };
    return UserPageView;
  })();
}).call(this);
