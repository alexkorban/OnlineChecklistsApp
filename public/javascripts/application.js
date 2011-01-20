(function() {
  var AppController, Checklist, ChecklistCollection, ChecklistListView, ChecklistView, Item, app, root;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  root = this;
  String.prototype.starts_with = function(str) {
    return this.match("^" + str) === str;
  };
  String.prototype.ends_with = function(str) {
    return this.match(str + "$") === str;
  };
  root.append_fn = function(fn, fn_to_append) {
    if (!(fn != null)) {
      return fn_to_append;
    } else {
      return function() {
        fn();
        return fn_to_append();
      };
    }
  };
  app = {
    active_page: function() {
      return $("#content");
    },
    go_back: function() {
      return $.historyBack();
    }
  };
  Item = (function() {
    __extends(Item, Backbone.Model);
    function Item() {
      Item.__super__.constructor.apply(this, arguments);
    }
    Item.prototype.content = function() {
      return this.get("content");
    };
    return Item;
  })();
  Checklist = (function() {
    __extends(Checklist, Backbone.Model);
    function Checklist() {
      Checklist.__super__.constructor.apply(this, arguments);
    }
    Checklist.prototype.name = function() {
      return this.get("name");
    };
    return Checklist;
  })();
  ChecklistCollection = (function() {
    __extends(ChecklistCollection, Backbone.Collection);
    ChecklistCollection.prototype.model = Checklist;
    ChecklistCollection.prototype.url = "/checklists";
    function ChecklistCollection() {
      ChecklistCollection.__super__.constructor.apply(this, arguments);
    }
    return ChecklistCollection;
  })();
  this.Checklists = new ChecklistCollection;
  ChecklistListView = (function() {
    __extends(ChecklistListView, Backbone.View);
    function ChecklistListView() {
      ChecklistListView.__super__.constructor.apply(this, arguments);
      this.el = app.active_page();
      this.template = _.template('<div>\n<ul>\n<% checklists.each(function(checklist) { %>\n<li><a href="#checklists-<%= checklist.cid %>"><%= checklist.name() %></a></li>\n<% }); %>\n</ul>\n</div>');
      this.render();
    }
    ChecklistListView.prototype.render = function() {
      console.log("rendering checklist list");
      return this.el.html(this.template({
        checklists: Checklists
      }));
    };
    return ChecklistListView;
  })();
  ChecklistView = (function() {
    __extends(ChecklistView, Backbone.View);
    function ChecklistView() {
      ChecklistView.__super__.constructor.apply(this, arguments);
      this.el = app.active_page();
      this.template = _.template('<div>\n<ul>\n<% items.each(function(item) { %>\n<li><a href="#items-<%= item.cid %>"><%= item.content() %></a></li>\n<% }); %>\n</ul>\n</div>');
      this.render();
    }
    ChecklistView.prototype.render = function() {
      console.log("rendering checklist");
      return this.el.html(this.template({
        items: Items
      }));
    };
    return ChecklistView;
  })();
  AppController = (function() {
    __extends(AppController, Backbone.Controller);
    AppController.prototype.routes = {
      "checklists-:cid-edit": "edit",
      "checklists-:cid": "show",
      "checklists": "checklists"
    };
    function AppController() {
      AppController.__super__.constructor.apply(this, arguments);
      this.views = {};
    }
    AppController.prototype.checklists = function() {
      var _base;
      console.log("in AppController.checklists");
      return (_base = this.views)['checklists'] || (_base['checklists'] = new ChecklistListView);
    };
    return AppController;
  })();
  app.appController = new AppController();
  $(document).ready(function() {
    return $.getJSON("/checklists", __bind(function(data, textStatus, xhr) {
      console.log(data);
      Checklists.refresh(data);
      Checklists.each(function(checklist) {
        return console.log(JSON.stringify(checklist));
      });
      Backbone.history.start();
      return app.appController.checklists();
    }, this));
  });
  this.app = app;
}).call(this);
