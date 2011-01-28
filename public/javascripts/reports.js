(function() {
  var Report, root;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  root = this;
  Report = (function() {
    __extends(Report, Backbone.Model);
    function Report() {
      Report.__super__.constructor.apply(this, arguments);
    }
    return Report;
  })();
  root.ReportPageView = (function() {
    __extends(ReportPageView, Backbone.View);
    ReportPageView.prototype.id = "content";
    ReportPageView.prototype.tagName = "div";
    function ReportPageView() {
      ReportPageView.__super__.constructor.apply(this, arguments);
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<h1>Reports</h1>\n<ul>\n  <li><a href = "#timeline">Timeline</a></li>\n  <li><a href = "#charts">Charts</a></li>\n</ul>');
      this.render();
    }
    ReportPageView.prototype.render = function() {
      return $(this.el).html(this.template());
    };
    return ReportPageView;
  })();
  root.TimelineView = (function() {
    __extends(TimelineView, Backbone.View);
    TimelineView.prototype.id = "content";
    TimelineView.prototype.tagName = "div";
    function TimelineView(users, checklists) {
      TimelineView.__super__.constructor.apply(this, arguments);
      this.users = users;
      this.checklists = checklists;
      this.all = "- All -";
      console.log(this.users);
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<h1>Reports &gt; Timeline</h1>\n<div class = "controls">\n  <a href = "#" class = "prev_week">Prev week</a>\n  <a href = "#" class = "next_week">Next week</a>\n  User:\n  <select class = "users">\n    <option><%= all %></option>\n    <% users.each(function(user) { %>\n      <option value = "<%= user.cid %>"><%= user.name() == null || user.name().length == 0 ? user.email() : user.name() %></option>\n    <% }); %>\n  </select>\n  Checklist:\n  <select class = "checklists">\n    <option><%= all %></option>\n    <% checklists.each(function(checklist) { %>\n      <option value = "<%= checklist.cid %>"><%= checklist.name() %></option>\n    <% }); %>\n  </select>\n</div>\n<% _.each(entries_by_day, function(entries, day) { %>\n  <h2><%= day %></h2>\n  <% _.each(entries, function(entry) { %>\n    <% console.log(day, ": ", entry); %>\n    <%= entry["for"] %> <%= entry.user_name %> <%= entry.display_time %><br/>\n  <% }); %>\n<% }); %>');
      $.getJSON("/entries", __bind(function(data, textStatus, xhr) {
        this.entries_by_day = data;
        return this.render();
      }, this));
    }
    TimelineView.prototype.render = function() {
      return $(this.el).html(this.template({
        all: this.all,
        users: this.users,
        checklists: this.checklists,
        entries_by_day: this.entries_by_day
      }));
    };
    return TimelineView;
  })();
}).call(this);
