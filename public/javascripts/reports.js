(function() {
  var Chart, ChecklistDropdown, Report, root;
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
  ChecklistDropdown = (function() {
    __extends(ChecklistDropdown, Backbone.View);
    ChecklistDropdown.prototype.tagName = "select";
    function ChecklistDropdown(args) {
      ChecklistDropdown.__super__.constructor.apply(this, arguments);
      this.checklists = args.checklists;
      this.allow_all = (args.allow_all != null) && args.allow_all === true;
      this.id = args.id;
      this.template = _.template('<select id = "checklists" class = "filter">\n  <% if (allow_all) { %> <option value = "0">- All -</option> <% } %>\n  <% checklists.each(function(checklist) { %>\n    <option value = "<%= checklist.id %>"><%= checklist.name() %></option>\n  <% }); %>\n</select>');
    }
    ChecklistDropdown.prototype.render = function() {
      console.log("rendering checklist", this.el, this.checklists);
      $("#" + this.id).replaceWith(this.template({
        allow_all: this.allow_all,
        checklists: this.checklists
      }));
      return console.log("after", this.el);
    };
    return ChecklistDropdown;
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
      this.user_id = args.user_id != null ? args.user_id : 0;
      this.checklist_id = args.checklist_id != null ? args.checklist_id : 0;
      this.all = "- All -";
      console.log(this.users);
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<h1>Reports &gt; Timeline</h1>\n<div class = "controls">\n  <a href = "#<%= prev_week_link %>" class = "prev_week">Prev week</a>\n  <% if (next_week_link != null) { %>\n    <a href = "#<%= next_week_link %>" class = "next_week">Next week</a>\n  <% } %>\n  User:\n  <select id = "users" class = "filter">\n    <option value = "0"><%= all %></option>\n    <% users.each(function(user) { %>\n      <option value = "<%= user.id %>"><%= user.name() == null || user.name().length == 0 ? user.email() : user.name() %></option>\n    <% }); %>\n  </select>\n  Checklist:\n  <select id = "checklists"></select>\n</div>\n<% _.each(entries_by_day, function(entries, day) { %>\n  <h2><%= day %></h2>\n  <% _.each(entries, function(entry) { %>\n    <%= entry["for"] %> <%= entry.user_name %> <%= entry.display_time %><br/>\n  <% }); %>\n<% }); %>');
      this.checklist_dropdown = new ChecklistDropdown({
        id: "checklists",
        checklists: this.checklists,
        allow_all: true
      });
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
      this.checklist_dropdown.render();
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
  Chart = (function() {
    __extends(Chart, Backbone.View);
    Chart.prototype.id = "chart";
    Chart.prototype.tagName = "div";
    function Chart(args) {
      this.render = __bind(this.render, this);;      Chart.__super__.constructor.apply(this, arguments);
      this.checklist_id = args.checklist_id;
      $("#" + this.id).replaceWith(this.el);
      console.log("el in constructor: ", this.el);
    }
    Chart.prototype.counts_url = function() {
      return "/entries/counts?checklist_id=" + this.checklist_id;
    };
    Chart.prototype.render = function() {
      console.log("starting to render chart");
      return $.getJSON(this.counts_url(), __bind(function(data, textStatus, xhr) {
        this.counts = data;
        return google.load('visualization', '1', {
          'packages': ['corechart'],
          callback: __bind(function() {
            var chart;
            console.log("creating chart");
            data = new google.visualization.DataTable();
            console.log("created data table");
            data.addColumn('string', 'Task');
            data.addColumn('number', 'Hours per Day');
            data.addRows([['Work', 11], ['Eat', 2], ['Commute', 2], ['Watch TV', 2], ['Sleep', 7]]);
            console.log("added data");
            chart = new google.visualization.PieChart(document.getElementById('chart'));
            console.log("chart: ", chart);
            return chart.draw(data, {
              width: 400,
              height: 240,
              is3D: true,
              title: 'My Daily Activities'
            });
          }, this)
        });
      }, this));
    };
    return Chart;
  })();
  root.ChartView = (function() {
    __extends(ChartView, Backbone.View);
    ChartView.prototype.tagName = "div";
    ChartView.prototype.id = "content";
    ChartView.prototype.events = {
      "change .filter": "on_change_filter"
    };
    function ChartView(args) {
      ChartView.__super__.constructor.apply(this, arguments);
      this.users = args.users;
      this.checklists = args.checklists;
      this.checklist_id = args.checklist_id;
      this.all = "- All -";
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<h1>Reports &gt; Charts</h1>\n<div class = "controls">\n  Checklist:\n  <select id = "checklists"></select>\n</div>\n<div id = "chart"></div>');
      this.checklist_dropdown = new ChecklistDropdown({
        id: "checklists",
        checklists: this.checklists
      });
      if (!(this.checklist_id != null)) {
        this.checklist_id = this.checklists.at(0).id;
      }
      this.chart = new Chart({
        checklist_id: this.checklist_id
      });
      this.render();
    }
    ChartView.prototype.render = function() {
      $(this.el).html(this.template({
        checklists: this.checklists,
        all: this.all,
        chart_url: this.chart_url()
      }));
      this.checklist_dropdown.render();
      return this.chart.render();
    };
    ChartView.prototype.chart_url = function() {
      var url;
      return url = "http://aoteastudios.com/images/logo.png";
    };
    ChartView.prototype.link = function() {
      var link;
      link = "charts";
      link += "/u0";
      link += "/c" + this.checklist_id;
      return link;
    };
    ChartView.prototype.on_change_filter = function(e) {
      if (e.target.id === "checklists") {
        this.checklist_id = $(e.target).val();
      }
      window.location.hash = this.link();
      return e.preventDefault();
    };
    return ChartView;
  })();
}).call(this);
