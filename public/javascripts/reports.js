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
    TimelineView.prototype.events = {
      "change .filter": "on_change_filter"
    };
    function TimelineView(args) {
      TimelineView.__super__.constructor.apply(this, arguments);
      this.users = args.users;
      this.checklists = args.checklists;
      this.week_offset = args.week_offset != null ? Number(args.week_offset) : 0;
      this.user_id = args.user_id;
      this.checklist_id = args.checklist_id;
      this.all = "- All -";
      console.log(this.users);
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<h1>Reports &gt; Timeline</h1>\n<div class = "controls">\n  <a href = "#<%= prev_week_link %>" class = "prev_week">Prev week</a>\n  <% if (next_week_link != null) { %>\n    <a href = "#<%= next_week_link %>" class = "next_week">Next week</a>\n  <% } %>\n  User:\n  <select id = "users" class = "filter">\n    <option value = "0"><%= all %></option>\n    <% users.each(function(user) { %>\n      <option value = "<%= user.id %>"><%= user.name() == null || user.name().length == 0 ? user.email() : user.name() %></option>\n    <% }); %>\n  </select>\n  Checklist:\n  <select id = "checklists" class = "filter">\n    <option value = "0"><%= all %></option>\n    <% checklists.each(function(checklist) { %>\n      <option value = "<%= checklist.id %>"><%= checklist.name() %></option>\n    <% }); %>\n  </select>\n</div>\n<% _.each(entries_by_day, function(entries, day) { %>\n  <h2><%= day %></h2>\n  <% _.each(entries, function(entry) { %>\n    <%= entry["for"] %> <%= entry.user_name %> <%= entry.display_time %><br/>\n  <% }); %>\n<% }); %>');
      $.getJSON(this.entries_url(), __bind(function(data, textStatus, xhr) {
        this.entries_by_day = data;
        return this.render();
      }, this));
    }
    TimelineView.prototype.render = function() {
      $(this.el).html(this.template({
        all: this.all,
        users: this.users,
        checklists: this.checklists,
        entries_by_day: this.entries_by_day,
        next_week_link: this.next_week_link(),
        prev_week_link: this.prev_week_link()
      }));
      if (this.user_id) {
        this.$("#users").val(this.user_id);
      }
      if (this.checklist_id) {
        return this.$("#checklists").val(this.checklist_id);
      }
    };
    TimelineView.prototype.next_week_link = function() {
      if (this.week_offset === 0) {
        return null;
      }
      return this.link(this.week_offset - 1);
    };
    TimelineView.prototype.prev_week_link = function() {
      return this.link(this.week_offset + 1);
    };
    TimelineView.prototype.link = function(offset) {
      var link;
      link = "timeline/" + offset;
      link += "/u" + this.user_id;
      link += "/c" + this.checklist_id;
      return link;
    };
    TimelineView.prototype.entries_url = function() {
      var url;
      url = "/entries/?week_offset=" + this.week_offset;
      url += "&user_id=" + this.user_id;
      url += "&checklist_id=" + this.checklist_id;
      return url;
    };
    TimelineView.prototype.on_change_filter = function(e) {
      if (e.target.id === "users") {
        this.user_id = $(e.target).val();
      }
      if (e.target.id === "checklists") {
        this.checklist_id = $(e.target).val();
      }
      window.location.hash = this.link(this.week_offset);
      return e.preventDefault();
    };
    return TimelineView;
  })();
}).call(this);
