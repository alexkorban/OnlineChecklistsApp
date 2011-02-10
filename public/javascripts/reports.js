(function() {
  var ChecklistDropdown, PieChart, Report, TimelineChart, root;
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
      this.template = _.template('<ul>\n  <li><a href = "#timeline">Timeline</a></li>\n  <li><a href = "#charts">Charts</a></li>\n</ul>');
      this.render();
    }
    ReportPageView.prototype.render = function() {
      $(this.el).html(this.template());
      return $("#heading").html("Reports");
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
      return $("#" + this.id).replaceWith(this.template({
        allow_all: this.allow_all,
        checklists: this.checklists
      }));
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
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<div class = "report_controls">\n  <div class = "prev_week">\n    <img src = "/images/left_32.png" />\n    <a href = "#<%= prev_week_link %>">Prev week</a>\n  </div>\n  <% if (next_week_link != null) { %>\n    <div class = "next_week">\n      <a href = "#<%= next_week_link %>">Next week</a>\n      <img src = "/images/right_32.png" />\n    </div>\n  <% } %>\n  <div style = "display: inline-block; padding-right: 50px">\n    User:\n    <select id = "users" class = "filter">\n      <option value = "0"><%= all %></option>\n      <% users.each(function(user) { %>\n        <option value = "<%= user.id %>"><%= user.name() == null || user.name().length == 0 ? user.email() : user.name() %></option>\n      <% }); %>\n    </select>\n  </div>\n  Checklist:\n  <select id = "checklists"></select>\n</div>\n<% _.each(entries_by_day, function(entries, day) { %>\n  <h2><%= day %></h2>\n  <table class = "timeline_entries">\n    <tr>\n      <th>Checklist</th>\n      <th>User</th>\n      <th>Completed at</th>\n      <th>Completed for</th>\n    </tr>\n\n    <% _.each(entries, function(entry) { %>\n      <tr>\n        <td class = "first"><%= entry.checklist_name %></td>\n        <td><%= entry.user_name %></td>\n        <td><%= entry.display_time %></td>\n        <td><%= entry.for %></td>\n      </tr>\n    <% }); %>\n  </table>\n<% }); %>');
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
      $("#heading").html("Reports &gt; Timeline");
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
  PieChart = (function() {
    __extends(PieChart, Backbone.View);
    PieChart.prototype.id = "pie_chart";
    PieChart.prototype.tagName = "div";
    function PieChart(args) {
      this.render = __bind(this.render, this);;      PieChart.__super__.constructor.apply(this, arguments);
      this.counts = args.counts;
      this.users = args.users;
      this.user_ids = args.user_ids;
    }
    PieChart.prototype.render = function() {
      return google.load('visualization', '1', {
        'packages': ['corechart'],
        callback: __bind(function() {
          var data, i, _ref;
          data = new google.visualization.DataTable();
          data.addColumn('string', 'Task');
          data.addColumn('number', 'Hours per Day');
          for (i = 0, _ref = this.user_ids.length - 1; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
            data.addRow([(this.user_ids[i] === 0 ? "Total" : this.users.get(this.user_ids[i]).name()), this.counts[i + 1]]);
          }
          this.chart = new google.visualization.PieChart(document.getElementById('_' + this.id));
          return this.chart.draw(data, {
            width: 400,
            height: 240,
            is3D: true,
            title: 'My Daily Activities'
          });
        }, this)
      });
    };
    return PieChart;
  })();
  TimelineChart = (function() {
    __extends(TimelineChart, Backbone.View);
    TimelineChart.prototype.id = "timeline_chart";
    TimelineChart.prototype.tagName = "div";
    function TimelineChart(args) {
      this.render = __bind(this.render, this);;      TimelineChart.__super__.constructor.apply(this, arguments);
      this.counts = args.counts;
      this.users = args.users;
      this.user_ids = args.user_ids;
      this.first_render = true;
    }
    TimelineChart.prototype.render = function() {
      return google.load('visualization', '1', {
        'packages': ['annotatedtimeline'],
        callback: __bind(function() {
          var data, i, id, _i, _len, _ref, _ref2;
          data = new google.visualization.DataTable();
          data.addColumn('date', 'Date');
          _ref = this.user_ids;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            id = _ref[_i];
            data.addColumn('number', id === 0 ? "Total" : this.users.get(id).name());
          }
          data.addRows(this.counts);
          this.chart = new google.visualization.AnnotatedTimeLine(document.getElementById(this.id));
          this.chart.draw(data, {
            displayAnnotations: false
          });
          if (this.first_render) {
            for (i = 0, _ref2 = this.user_ids.length - 1; (0 <= _ref2 ? i < _ref2 : i > _ref2); (0 <= _ref2 ? i += 1 : i -= 1)) {
              this.chart.hideDataColumns(i);
            }
            return this.first_render = false;
          }
        }, this)
      });
    };
    return TimelineChart;
  })();
  root.ChartView = (function() {
    __extends(ChartView, Backbone.View);
    ChartView.prototype.tagName = "div";
    ChartView.prototype.id = "content";
    ChartView.prototype.events = {
      "change .filter": "on_change_filter",
      "change .month": "on_change_month",
      "change .user_checkbox": "on_change_user_checkbox"
    };
    function ChartView(args) {
      ChartView.__super__.constructor.apply(this, arguments);
      this.users = args.users;
      this.checklists = args.checklists;
      this.users = args.users;
      this.checklist_id = args.checklist_id;
      this.all = "- All -";
      this.checklist_dropdown = new ChecklistDropdown({
        id: "checklists",
        checklists: this.checklists
      });
      if (!(this.checklist_id != null)) {
        this.checklist_id = this.checklists.at(0).id;
      }
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<div class = "controls">\n  Checklist:\n  <select id = "checklists"></select>\n</div>\n<div style = "text-align: top">\n  <div id = "timeline_chart" style=\'width: 700px; height: 400px; display: inline-block\'></div>\n  <div id = "user_list" style  = "display: inline-block; min-height: 400px">\n    <input type = "checkbox" class = "user_checkbox" value = "0" id = "checkbox_0" checked = "checked" /><label for="checkbox_0"><%= all %></label><br/>\n    <% _.each(users.models, function(user) { %>\n      <input type = "checkbox" class = "user_checkbox" id = "checkbox_<%= user.id %>" value = "<%= user.id %>" /><label for="checkbox_<%= user.id %>"><%= user.name() %></label><br/>\n    <% }); %>\n  </div>\n</div>\n<div id = "pie_chart">\n  <select class = "month">\n    <% months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]; %>\n    <% _.each(counts, function(count, index) { %>\n      <option value = "<%= index %>"\n        <% if (index == counts.length - 1) { %> selected = "selected" <% } %> >\n        <%= months[count[0].getMonth()] + \' \' + String(count[0].getYear() + 1900) %></option>\n    <% }); %>\n  </select>\n  <div id = "_pie_chart"></div>\n</div>');
      $.getJSON(this.counts_url(), __bind(function(data, textStatus, xhr) {
        var item, _i, _len, _ref;
        this.counts = data.counts;
        if (this.counts.length > 0) {
          _ref = this.counts;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            item[0] = new Date(item[0]);
          }
          this.user_ids = data.user_ids;
          this.timeline_chart = new TimelineChart({
            counts: this.counts,
            users: this.users,
            user_ids: this.user_ids
          });
          this.pie_chart = new PieChart({
            users: this.users,
            user_ids: this.user_ids,
            counts: this.counts[this.counts.length - 1]
          });
        }
        return this.render();
      }, this));
    }
    ChartView.prototype.render = function() {
      $(this.el).html(this.template({
        checklists: this.checklists,
        users: this.users,
        counts: this.counts,
        all: this.all
      }));
      $("#heading").html("Reports &gt; Charts");
      this.checklist_dropdown.render();
      if (this.counts.length > 0) {
        this.timeline_chart.render();
        this.pie_chart.render();
      } else {
        this.$("#timeline_chart").html("<b>No data available</b>");
      }
      return this.$("#checklists").val(this.checklist_id);
    };
    ChartView.prototype.link = function() {
      var link;
      link = "charts";
      link += "/u0";
      link += "/c" + this.checklist_id;
      return link;
    };
    ChartView.prototype.counts_url = function() {
      return "/entries/counts?checklist_id=" + this.checklist_id;
    };
    ChartView.prototype.on_change_filter = function(e) {
      if (e.target.id === "checklists") {
        this.checklist_id = $(e.target).val();
      }
      window.location.hash = this.link();
      return e.preventDefault();
    };
    ChartView.prototype.on_change_month = function(e) {
      this.pie_chart.counts = this.counts[Number($(e.target).val())];
      return this.pie_chart.render();
    };
    ChartView.prototype.on_change_user_checkbox = function(e) {
      var index;
      index = _.lastIndexOf(this.user_ids, Number($(e.target).val()));
      if ($(e.target).is(":checked")) {
        return this.timeline_chart.chart.showDataColumns(index);
      } else {
        return this.timeline_chart.chart.hideDataColumns(index);
      }
    };
    return ChartView;
  })();
}).call(this);
