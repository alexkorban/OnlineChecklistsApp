(function() {
  var AppController, heartbeat, root;
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
      "": "checklists",
      "checklists": "checklists",
      "checklists/:cid/edit": "edit",
      "checklists/:cid": "show",
      "timezone": "timezone",
      "create": "create",
      "users": "users",
      "timeline": "timeline",
      "timeline/:week_offset/u:user_id/c:checklist_id": "timeline",
      "charts": "charts",
      "charts/c:checklist_id/g:group_by": "charts"
    };
    function AppController() {
      AppController.__super__.constructor.apply(this, arguments);
      this.flash = null;
    }
    AppController.prototype.get_flash = function() {
      var res;
      res = this.flash;
      this.flash = null;
      return res;
    };
    AppController.prototype.checklists = function() {
      if (!(current_account.time_zone != null) || current_account.time_zone.length === 0) {
        return window.location.hash = "timezone";
      } else {
        this.view = new ChecklistListView;
        return this.saveLocation("checklists");
      }
    };
    AppController.prototype.timezone = function() {
      return this.view = new TimeZoneView;
    };
    AppController.prototype.show = function(cid) {
      this.view = new ChecklistView({
        model: Checklists.getByCid(cid)
      });
      return this.saveLocation("checklists/" + cid);
    };
    AppController.prototype.create = function() {
      var c;
      c = new Checklist;
      Checklists.add(c);
      this.view = new EditChecklistView({
        model: c
      });
      return this.saveLocation("create");
    };
    AppController.prototype.edit = function(cid) {
      this.view = new EditChecklistView({
        model: Checklists.getByCid(cid)
      });
      return this.saveLocation("checklists/" + cid + "/edit");
    };
    AppController.prototype.users = function() {
      if (current_user.role === "admin") {
        this.view = new UserPageView({
          users: Users
        });
        return this.saveLocation("users");
      }
    };
    AppController.prototype.timeline = function(week_offset, user_id, checklist_id) {
      this.view = new TimelineView({
        week_offset: week_offset,
        users: Users,
        checklists: Checklists,
        user_id: user_id,
        checklist_id: checklist_id
      });
      return this.saveLocation("timeline");
    };
    AppController.prototype.charts = function(checklist_id, group_by) {
      if (Checklists.length > 0 && !(checklist_id != null)) {
        checklist_id = Checklists.at(0).id;
      }
      if (!(group_by != null)) {
        group_by = "day";
      }
      this.view = new ChartView({
        checklist_id: checklist_id,
        group_by: group_by,
        users: Users,
        checklists: Checklists
      });
      return this.saveLocation("charts");
    };
    return AppController;
  })();
  heartbeat = function() {
    return $.ajax({
      url: "/heartbeat",
      dataType: "json",
      error: function(xhr) {
        if (xhr.status === 200) {
          return window.location.href = "/users/sign_in";
        }
      }
    });
  };
  $(function() {
    window.app = new AppController();
    Backbone.history.start();
    setInterval(heartbeat, 5 * 60 * 1000);
    return $(document).keypress(function(e) {
      var last_selected, next;
      if (e.keyCode !== 13) {
        return;
      }
      if ($("#completion_message").is(":visible")) {
        $(".complete").click();
        return;
      }
      if (e.target.name === "notes") {
        $(".checklist_item").not(".checked").first().toggleClass("selected");
        $(e.target).blur();
        if ($(".checklist_item").length === 0) {
          $("#completion_message").show();
        }
        e.preventDefault();
        return;
      }
      last_selected = $(".checklist_item.selected");
      next = last_selected.length > 0 ? last_selected.next(".checklist_item").not(".checked") : $(".checklist_item").not(".checked").first();
      last_selected.addClass("checked").removeClass("selected");
      if (next.length > 0) {
        next.addClass("selected");
        $("body").focus();
        return e.preventDefault();
      } else {
        if ($(".checklist_item").not(".checked").length === 0) {
          $("#completion_message").show();
          $("#incomplete_warning").hide();
          return e.preventDefault();
        }
      }
    });
  });
}).call(this);
