(function() {
  var AppController, appController, root;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  root = this;
  String.prototype.starts_with = function(str) {
    return this.match("^" + str) === str;
  };
  String.prototype.ends_with = function(str) {
    return this.match(str + "$") === str;
  };
  jQuery.fn.log = function(msg) {
    console.log("%s: %o", msg, this);
    return this;
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
  Backbone.emulateHTTP = true;
  AppController = (function() {
    __extends(AppController, Backbone.Controller);
    AppController.prototype.routes = {
      "checklists-:cid-edit": "edit",
      "checklists-:cid": "show",
      "checklists": "checklists",
      "": "checklists",
      "create": "create",
      "users": "users",
      "reports": "reports",
      "timeline": "timeline",
      "timeline-:week_offset": "timeline",
      "charts": "charts"
    };
    function AppController() {
      AppController.__super__.constructor.apply(this, arguments);
    }
    AppController.prototype.checklists = function() {
      return this.view = new ChecklistListView;
    };
    AppController.prototype.show = function(cid) {
      return this.view = new ChecklistView({
        model: Checklists.getByCid(cid)
      });
    };
    AppController.prototype.create = function() {
      var c;
      c = new Checklist;
      Checklists.add(c);
      return this.view = new EditChecklistView({
        model: c
      });
    };
    AppController.prototype.edit = function(cid) {
      return this.view = new EditChecklistView({
        model: Checklists.getByCid(cid)
      });
    };
    AppController.prototype.users = function() {
      return this.view = new UserPageView({
        users: this.users
      });
    };
    AppController.prototype.reports = function() {
      return this.view = new ReportPageView;
    };
    AppController.prototype.timeline = function(week_offset) {
      return this.view = new TimelineView(week_offset, Users, Checklists);
    };
    AppController.prototype.charts = function() {
      return this.view = new ChartsView(Users, Checklists);
    };
    return AppController;
  })();
  appController = new AppController();
  $(document).ready(function() {
    return Backbone.history.start();
  });
  this.app = appController;
}).call(this);
