(function() {
  var Invitation, InvitationCollection, User, UserCollection, root;
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
      return this.get("email");
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
  Invitation = (function() {
    __extends(Invitation, Backbone.Model);
    function Invitation() {
      Invitation.__super__.constructor.apply(this, arguments);
    }
    Invitation.prototype.email = function() {
      return this.get("email");
    };
    return Invitation;
  })();
  InvitationCollection = (function() {
    __extends(InvitationCollection, Backbone.Collection);
    InvitationCollection.prototype.model = Invitation;
    InvitationCollection.prototype.url = "/users/invitations";
    function InvitationCollection() {
      InvitationCollection.__super__.constructor.apply(this, arguments);
    }
    return InvitationCollection;
  })();
  root.UserListView = (function() {
    __extends(UserListView, Backbone.View);
    UserListView.prototype.tagName = "div";
    UserListView.prototype.id = "user_list";
    function UserListView() {
      UserListView.__super__.constructor.apply(this, arguments);
      this.template = _.template('<ul>\n<% users.each(function(user) { %>\n<li><a href="#users-<%= user.cid %>"><%= user.name() %></a>\n  (<a href = "#users-<%= user.cid %>-edit">Edit</a> | <a id = "remove_<%= user.cid %>" class = "remove" href = "#">X</a>)</li>\n<% }); %>\n</ul>');
      this.users = new UserCollection;
      this.users.fetch({
        success: __bind(function() {
          return this.render();
        }, this)
      });
    }
    UserListView.prototype.render = function() {
      $(this.el).html(this.template({
        users: this.users
      }));
      return $("#" + this.id).replaceWith(this.el);
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
      this.template = _.template('<input type = "text" value = "<%= item.email() %>" /> <a href = "#" class = "remove_item">X</a>');
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
      return this.model.set({
        "email": $(e.target).val()
      });
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
    function InvitationView() {
      this.remove_item = __bind(this.remove_item, this);;
      this.add_item = __bind(this.add_item, this);;      InvitationView.__super__.constructor.apply(this, arguments);
      this.template = _.template('<h2>Invite users</h2>\n<div id = "invitation_items"></div>\n<a href = "#" class = "add_item">Add item</a>\n<br/>\n<a href = "#checklists" class = "save">Save</a>');
      this.render();
      this.invitations = new InvitationCollection;
      this.invitations.bind("add", this.add_item);
      this.invitations.bind("remove", this.remove_item);
      this.invitations.add(new Invitation);
    }
    InvitationView.prototype.render = function() {
      $(this.el).html(this.template());
      $("#" + this.id).replaceWith(this.el);
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
      var invitation, _i, _len, _ref, _results;
      _ref = this.invitations.models;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        invitation = _ref[_i];
        _results.push(invitation.email().length > 0 ? invitation.save() : void 0);
      }
      return _results;
    };
    return InvitationView;
  })();
  root.UserPageView = (function() {
    __extends(UserPageView, Backbone.View);
    UserPageView.prototype.tagName = "div";
    UserPageView.prototype.id = "content";
    function UserPageView() {
      UserPageView.__super__.constructor.apply(this, arguments);
      this.template = _.template('<h1>Users</h1>\n<div id = "user_list"></div>\n<div id = "invitations"></div>');
      this.render();
      this.user_list_view = new UserListView;
      this.invitation_view = new InvitationView;
    }
    UserPageView.prototype.render = function() {
      $(this.el).html(this.template({
        users: this.users
      }));
      return $("#" + this.id).replaceWith(this.el);
    };
    return UserPageView;
  })();
}).call(this);
