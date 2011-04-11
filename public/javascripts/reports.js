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
  ChecklistDropdown = (function() {
    __extends(ChecklistDropdown, Backbone.View);
    ChecklistDropdown.prototype.tagName = "select";
    function ChecklistDropdown(args) {
      ChecklistDropdown.__super__.constructor.apply(this, arguments);
      this.checklists = args.checklists;
      this.allow_all = (args.allow_all != null) && args.allow_all === true;
      this.id = args.id;
      this.template = _.template('<select id = "checklists" class = "filter">\n  <% if (allow_all) { %> <option value = "0">- All -</option> <% } %>\n  <% _.each(checklists, function(checklist) { %>\n    <option value = "<%= checklist.id %>"><%= checklist.name %></option>\n  <% }); %>\n</select>');
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
      this.all = "- All -";
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<div id = "buttons">\n  <a class = "button" href = "#checklists">Go to checklists</a>\n  <a class = "button" href = "#charts">View charts</a>\n</div>\n<div class = "report_controls">\n  <div class = "prev_week">\n    <a href = "#<%= prev_week_link %>" style = "border: none"><img src = "/images/left_32.png" /></a>\n    <a href = "#<%= prev_week_link %>">Prev week</a>\n  </div>\n  <% if (next_week_link != null) { %>\n    <div class = "next_week">\n      <a href = "#<%= next_week_link %>">Next week</a>\n      <a href = "#<%= next_week_link %>" style = "border: none"><img src = "/images/right_32.png" /></a>\n    </div>\n  <% } %>\n  <div style = "display: inline-block; padding-right: 50px">\n    User:\n    <select id = "users" class = "filter">\n      <option value = "0"><%= all %></option>\n      <% _.each(users, function(user) { %>\n        <option value = "<%= user.id %>"><%= user.name == null || user.name.length == 0 ? user.email : user.name %></option>\n      <% }); %>\n    </select>\n  </div>\n  Checklist:\n  <select id = "checklists"></select>\n</div>\n<% if (entries_by_day.length == 0) { %>\n  <h2>No entries for this week</h2>\n<% } %>');
      this.day_entry_template = _.template('<h2><%= day_entry[0] %></h2>\n<table class = "timeline_entries" style = "width: 100%">\n  <tr>\n    <th style = "width: 40%">Checklist</th>\n    <th style = "width: 10%">User</th>\n    <th style = "width: 15%">Completed at</th>\n    <th style = "width: 35%">Notes</th>\n\n  </tr>\n</table>');
      this.day_entry_row_template = _.template('<tr>\n  <td style = "width: 40%" class = "first"><%= row.checklist_name %></td>\n  <td style = "width: 10%"><%= row.user_name %></td>\n  <td style = "width: 15%"><%= row.display_time %></td>\n  <td style = "width: 35%"><%= row.notes %></td>\n</tr>');
      this.no_entries_template = _.template('You\'ll need to\n<% if (checklists.length == 0) { %>\n  <a href = "#checklists">define some checklists</a> and get people to fill them out\n<% } else { %>\n  define some checklists and <a href = "#checklists">get people to fill them out</a>\n<% } %>\nto get reports and charts like this:<br/><br/>\n<img src = "/images/timeline-sample.png" style = "border: 2px solid #e0e0e0" />\n<img src = "/images/chart-sample.png" style = "border: 2px solid #e0e0e0" /><br/>');
      this.checklist_id = args.checklist_id != null ? args.checklist_id : 0;
      $.ajax({
        url: this.entries_url(),
        dataType: 'json',
        success: __bind(function(data, textStatus, xhr) {
          this.entries_by_day = data.entries;
          this.entries_checklists = data.checklists;
          this.users = data.users;
          this.checklist_dropdown = new ChecklistDropdown({
            id: "checklists",
            checklists: this.entries_checklists,
            allow_all: true
          });
          return this.render();
        }, this),
        error: __bind(function(xhr) {
          return this.render();
        }, this)
      });
    }
    TimelineView.prototype.render = function() {
      var day_entry, row, _i, _j, _len, _len2, _ref, _ref2;
      $("#heading").html("Reports &gt; Timeline");
      document.title = "OnlineChecklists: Reports > Timeline";
      if (this.entries_by_day != null) {
        $(this.el).html(this.template({
          all: this.all,
          users: this.users,
          entries_by_day: this.entries_by_day,
          next_week_link: this.next_week_link(),
          prev_week_link: this.prev_week_link()
        }));
        _ref = this.entries_by_day;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          day_entry = _ref[_i];
          $(this.el).append(this.day_entry_template({
            day_entry: day_entry
          }));
          _ref2 = day_entry[1];
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            row = _ref2[_j];
            this.$(".timeline_entries:last").append(this.day_entry_row_template({
              row: row
            }));
          }
        }
        this.checklist_dropdown.render();
        if (this.user_id) {
          this.$("#users").val(this.user_id);
        }
        if (this.checklist_id) {
          return this.$("#checklists").val(this.checklist_id);
        }
      } else {
        return $(this.el).html(this.no_entries_template({
          users: this.users,
          checklists: this.checklists
        }));
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
    }
    PieChart.prototype.render = function() {
      return google.load('visualization', '1', {
        'packages': ['corechart'],
        callback: __bind(function() {
          var data, i, _ref;
          data = new google.visualization.DataTable();
          data.addColumn('string', 'Task');
          data.addColumn('number', 'Hours per Day');
          for (i = 0, _ref = this.users.length - 1; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
            data.addRow([(this.users[i][0] === 0 ? "Total" : this.users[i][1]), this.counts[i + 1]]);
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
      this.colors = args.colors;
      this.first_render = true;
    }
    TimelineChart.prototype.render = function() {
      return google.load('visualization', '1', {
        'packages': ['annotatedtimeline'],
        callback: __bind(function() {
          var data, i, user, _i, _len, _ref, _ref2;
          data = new google.visualization.DataTable();
          data.addColumn('date', 'Date');
          _ref = this.users;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            user = _ref[_i];
            data.addColumn('number', user.name);
          }
          data.addRows(this.counts);
          this.chart = new google.visualization.AnnotatedTimeLine(document.getElementById(this.id));
          this.chart.draw(data, {
            displayAnnotations: false,
            colors: this.colors,
            displayZoomButtons: false,
            thickness: 2
          });
          if (this.first_render) {
            for (i = 1, _ref2 = this.users.length; (1 <= _ref2 ? i < _ref2 : i > _ref2); (1 <= _ref2 ? i += 1 : i -= 1)) {
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
      "change .user_checkbox": "on_change_user_checkbox"
    };
    ChartView.prototype.colors = ["#669999", "#99CC00", "#330000", "#FF9900", "#996666", "#990033", "#003399", "#9999CC", "#FFCC66", "#666600", "#9933CC", "#996633", "#666633", "#009900", "#33CC99", "#0099CC", "#333399", "#CC99CC", "#000099", "#66CCFF"];
    function ChartView(args) {
      ChartView.__super__.constructor.apply(this, arguments);
      this.users = args.users;
      this.checklists = args.checklists;
      this.checklist_id = args.checklist_id;
      this.group_by = args.group_by;
      this.all = "- All -";
      if (!(this.group_by != null)) {
        this.group_by = "day";
      }
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<div id = "buttons">\n  <a class = "button" href = "#checklists">Go to checklists</a>\n  <a class = "button" href = "#timeline">View timeline</a>\n</div>\n<div class = "report_controls">\n  Checklist:\n  <select id = "checklists"></select>\n  <span style = "padding-left: 40px">Totals:</span>\n  <select id = "group_by" class = "filter">\n    <option value = "day">Daily</option>\n    <option value = "week">Weekly</option>\n    <option value = "month">Monthly</option>\n  </select>\n</div>\n<div id = "daily_message" style = "padding-top: 20px">\n  Note: daily counts are only available for the last 30 days\n</div>\n<table style = "margin-top: 20px">\n  <tr>\n    <td>\n      <div id = "timeline_chart" style=\'width: 700px; height: 400px; display: inline-block\'></div>\n      <div style = "padding-top: 15px; width: 700px">\n        The chart shows the number of times the selected checklist has been completed by the selected users\n        during each reporting period (daily, weekly or monthly).\n        <br/><br/>\n        The summary chart below the main chart has handles which allow you to resize the visible area to get a more\n        detailed view at a certain period.\n        <br/><br/>\n        As you hover your mouse over the chart, you will see checklist completion counts for the selected date\n        shown at the top of the chart.\n      </div>\n    </td>\n    <td style = "padding-left: 20px; vertical-align: top">\n      <% _.each(users, function(user, index) { %>\n        <input type = "checkbox" class = "user_checkbox" id = "checkbox_<%= user.id %>" value = "<%= user.id %>"\n         <% if (user.id == 0) { %> checked = "checked" <% } %>\n        />\n        <label for="checkbox_<%= user.id %>" style = "color: <%= colors[_.lastIndexOf(users, user)] %>"><%= user.name %></label><br/>\n      <% }); %>\n    </td>\n  </tr>\n</table>');
      $.getJSON(this.counts_url(), __bind(function(data, textStatus, xhr) {
        var date_parts, item, _i, _len, _ref;
        this.counts = data.counts;
        this.count_users = data.users;
        this.count_checklists = data.checklists;
        if (this.counts.length > 0) {
          _ref = this.counts;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            date_parts = item[0].split("-");
            item[0] = new Date(date_parts[0], date_parts[1] - 1, date_parts[2]);
          }
        }
        this.checklist_dropdown = new ChecklistDropdown({
          id: "checklists",
          checklists: this.count_checklists
        });
        if (this.count_checklists.length > 0 && !(this.checklist_id != null)) {
          this.checklist_id = this.count_checklists.at(0).id;
        }
        this.timeline_chart = new TimelineChart({
          counts: this.counts,
          users: this.count_users,
          colors: this.colors
        });
        return this.render();
      }, this));
    }
    ChartView.prototype.render = function() {
      $(this.el).html(this.template({
        checklists: this.checklists,
        users: this.count_users,
        counts: this.counts,
        all: this.all,
        colors: this.colors,
        group_by: this.group_by
      }));
      $("#heading").html("Reports &gt; Charts");
      document.title = "OnlineChecklists: Reports > Charts";
      this.checklist_dropdown.render();
      if (this.group_by !== "day") {
        $("#daily_message").hide();
      }
      if (this.counts.length > 0) {
        this.timeline_chart.render();
      } else {
        this.$("#timeline_chart").html("<b>No data available</b>");
      }
      this.$("#checklists").val(this.checklist_id);
      return this.$("#group_by").val(this.group_by);
    };
    ChartView.prototype.link = function() {
      var link;
      link = "charts";
      link += "/c" + this.checklist_id;
      link += "/g" + this.group_by;
      return link;
    };
    ChartView.prototype.counts_url = function() {
      return "/entries/counts?checklist_id=" + this.checklist_id + "&group_by=" + this.group_by;
    };
    ChartView.prototype.on_change_filter = function(e) {
      if (e.target.id === "checklists") {
        this.checklist_id = $(e.target).val();
      }
      if (e.target.id === "group_by") {
        this.group_by = $(e.target).val();
      }
      window.location.hash = this.link();
      return e.preventDefault();
    };
    ChartView.prototype.on_change_user_checkbox = function(e) {
      return _.each(this.count_users, __bind(function(user, index) {
        if (user.id === Number($(e.target).val())) {
          if ($(e.target).is(":checked")) {
            return this.timeline_chart.chart.showDataColumns(index);
          } else {
            return this.timeline_chart.chart.hideDataColumns(index);
          }
        }
      }, this));
    };
    return ChartView;
  })();
}).call(this);
