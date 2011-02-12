root = this

class Report extends Backbone.Model
  constructor: ->
    super


class root.ReportPageView extends Backbone.View
  id: "content"
  tagName: "div"


  constructor: ->
    super

    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <ul>
        <li><a href = "#timeline">Timeline</a></li>
        <li><a href = "#charts">Charts</a></li>
      </ul>
    ''')

    @render()


  render: ->
    $(@el).html(@template())
    $("#heading").html("Reports")

class ChecklistDropdown extends Backbone.View
  tagName: "select"

  constructor: (args) ->
    super
    @checklists = args.checklists
    @allow_all = args.allow_all? && args.allow_all is yes
    @id = args.id
    #$("#" + @id).replaceWith(@el)

    @template = _.template('''
      <select id = "checklists" class = "filter">
        <% if (allow_all) { %> <option value = "0">- All -</option> <% } %>
        <% checklists.each(function(checklist) { %>
          <option value = "<%= checklist.id %>"><%= checklist.name() %></option>
        <% }); %>
      </select>
    ''')


  render: ->
    $("#" + @id).replaceWith(@template({allow_all: @allow_all, checklists: @checklists}))
    #@el = $("#" + @id)[0]


class root.TimelineView extends Backbone.View
  id: "content"
  tagName: "div"
  events: {
    "change .filter": "on_change_filter"
  }

  constructor: (args) ->
    super
    @users = args.users
    @checklists = args.checklists
    @week_offset = if args.week_offset? then Number(args.week_offset) else 0
    @user_id = if args.user_id? then args.user_id else 0
    @checklist_id = if args.checklist_id? then args.checklist_id else 0

    @all = "- All -"

    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <div class = "report_controls">
        <div class = "prev_week">
          <img src = "/images/left_32.png" />
          <a href = "#<%= prev_week_link %>">Prev week</a>
        </div>
        <% if (next_week_link != null) { %>
          <div class = "next_week">
            <a href = "#<%= next_week_link %>">Next week</a>
            <img src = "/images/right_32.png" />
          </div>
        <% } %>
        <div style = "display: inline-block; padding-right: 50px">
          User:
          <select id = "users" class = "filter">
            <option value = "0"><%= all %></option>
            <% users.each(function(user) { %>
              <option value = "<%= user.id %>"><%= user.name() == null || user.name().length == 0 ? user.email() : user.name() %></option>
            <% }); %>
          </select>
        </div>
        Checklist:
        <select id = "checklists"></select>
      </div>
      <% _.each(entries_by_day, function(entries, day) { %>
        <h2><%= day %></h2>
        <table class = "timeline_entries">
          <tr>
            <th>Checklist</th>
            <th>User</th>
            <th>Completed at</th>
            <th>Completed for</th>
          </tr>

          <% _.each(entries, function(entry) { %>
            <tr>
              <td class = "first"><%= entry.checklist_name %></td>
              <td><%= entry.user_name %></td>
              <td><%= entry.display_time %></td>
              <td><%= entry.for %></td>
            </tr>
          <% }); %>
        </table>
      <% }); %>
    ''')

    @checklist_dropdown = new ChecklistDropdown({id: "checklists", checklists: @checklists, allow_all: yes})
    $.getJSON @entries_url(), (data, textStatus, xhr) =>
      @entries_by_day = data
      @render()


  render: ->
    $(@el).html @template({
      all: @all
      users: @users
      checklists: @checklists
      entries_by_day: @entries_by_day
      next_week_link: @next_week_link()
      prev_week_link: @prev_week_link()
      })
    $("#heading").html("Reports &gt; Timeline")
    @checklist_dropdown.render()
    @$("#users").val(@user_id) if @user_id
    @$("#checklists").val(@checklist_id) if @checklist_id


  next_week_link: ->
    return null if @week_offset is 0
    @link(@week_offset - 1)


  prev_week_link: ->
    @link(@week_offset + 1)


  link: (offset) ->
    link = "timeline/#{offset}"
    link += "/u#{@user_id}"
    link += "/c#{@checklist_id}"
    link


  entries_url: ->
    url = "/entries/?week_offset=#{@week_offset}"
    url += "&user_id=#{@user_id}"
    url += "&checklist_id=#{@checklist_id}"
    url


  on_change_filter: (e) ->
    @user_id = $(e.target).val() if e.target.id is "users"
    @checklist_id = $(e.target).val() if e.target.id is "checklists"
    window.location.hash = @link(@week_offset)
    e.preventDefault()


class PieChart extends Backbone.View
  id: "pie_chart"
  tagName: "div"

  constructor: (args) ->
    super
    @counts = args.counts
    @users = args.users
    @user_ids = args.user_ids

    #$("#" + @id).replaceWith(@el)



  render: =>
    google.load('visualization', '1', {'packages':['corechart'], callback: =>
      data = new google.visualization.DataTable()
      data.addColumn('string', 'Task')
      data.addColumn('number', 'Hours per Day')
      for i in [0...@user_ids.length - 1]
        data.addRow([(if @user_ids[i] is 0 then "Total" else @users.get(@user_ids[i]).name()), @counts[i + 1]])
      # Instantiate and draw our chart, passing in some options.
      @chart = new google.visualization.PieChart(document.getElementById('_' + @id))
      @chart.draw(data, {width: 400, height: 240, is3D: true, title: 'My Daily Activities'})
    })


class TimelineChart extends Backbone.View
  id: "timeline_chart"
  tagName: "div"

  constructor: (args) ->
    super
    @counts = args.counts
    @users = args.users
    @user_ids = args.user_ids
    @first_render = true

    #$("#" + @id).replaceWith(@el)


  render: =>

      # Load the Visualization API and the piechart package.
    google.load('visualization', '1', {'packages':['annotatedtimeline'], callback: =>
      data = new google.visualization.DataTable()
      data.addColumn('date', 'Date')
      for id in @user_ids
        data.addColumn('number', if id is 0 then "Total" else @users.get(id).name())
      data.addRows(@counts)

      @chart = new google.visualization.AnnotatedTimeLine(document.getElementById(@id));
      @chart.draw(data, {displayAnnotations: false});
      if @first_render
        for i in [0...@user_ids.length - 1]
          @chart.hideDataColumns(i)
        @first_render = false
    })


class root.ChartView extends Backbone.View
  tagName: "div"
  id: "content"
  events: {
    "change .filter": "on_change_filter"
    "change .month" : "on_change_month"
    "change .user_checkbox" : "on_change_user_checkbox"
  }

  constructor: (args) ->
    super

    @users = args.users
    @checklists = args.checklists
    @users = args.users
    @checklist_id = args.checklist_id
    @group_by = args.group_by
    @all = "- All -"

    @checklist_dropdown = new ChecklistDropdown({id: "checklists", checklists: @checklists})
    @checklist_id = @checklists.at(0).id if !@checklist_id?
    @group_by = "day" if !@group_by?

    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <div class = "report_controls">
        Checklist:
        <select id = "checklists"></select>
        <span style = "padding-left: 40px">Totals:</span>
        <select id = "group_by" class = "filter">
          <option value = "day">Daily</option>
          <option value = "week">Weekly</option>
          <option value = "month">Monthly</option>
        </select>
        <span class = "daily">(daily counts are only available for the last 30 days)</span>
      </div>
      <div style = "text-align: top; margin-top: 20px">
        <div id = "timeline_chart" style='width: 700px; height: 400px; display: inline-block'></div>
        <div id = "user_list" style  = "display: inline-block; min-height: 400px">
          <input type = "checkbox" class = "user_checkbox" value = "0" id = "checkbox_0" checked = "checked" /><label for="checkbox_0"><%= all %></label><br/>
          <% _.each(users.models, function(user) { %>
            <input type = "checkbox" class = "user_checkbox" id = "checkbox_<%= user.id %>" value = "<%= user.id %>" /><label for="checkbox_<%= user.id %>"><%= user.name() %></label><br/>
          <% }); %>
        </div>
      </div>
      <div id = "pie_chart">
        <select class = "month">
          <% months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]; %>
          <% _.each(counts, function(count, index) { %>
            <option value = "<%= index %>"
              <% if (index == counts.length - 1) { %> selected = "selected" <% } %> >
              <%= months[count[0].getMonth()] + ' ' + String(count[0].getYear() + 1900) %></option>
          <% }); %>
        </select>
        <div id = "_pie_chart"></div>
      </div>
    ''')

    $.getJSON @counts_url(), (data, textStatus, xhr) =>
      @counts = data.counts #@type_cast(data.counts)

      if @counts.length > 0
        for item in @counts
          item[0] = new Date(item[0])

        @user_ids = data.user_ids

        @timeline_chart = new TimelineChart({counts: @counts, users: @users, user_ids: @user_ids})
        @pie_chart = new PieChart({users: @users, user_ids: @user_ids, counts: @counts[@counts.length - 1]})

      @render()


    #@$("#checklists").selectedIndex = 0


  render: ->
    $(@el).html(@template({checklists: @checklists, users: @users, counts: @counts, all: @all}))
    $("#heading").html("Reports &gt; Charts")
    @checklist_dropdown.render()
    if @counts.length > 0
      @timeline_chart.render()
      @pie_chart.render()
    else
      @$("#timeline_chart").html("<b>No data available</b>")
    @$("#checklists").val(@checklist_id)
    @$("#group_by").val(@group_by)
    @$(".daily").hide() if @group_by != "day"


  link: ->
    link = "charts"
    link += "/u0"
    link += "/c#{@checklist_id}"
    link += "/g#{@group_by}"
    link


  counts_url: ->
    "/entries/counts?checklist_id=#{@checklist_id}&group_by=#{@group_by}"


  on_change_filter: (e) ->
    #@user_id = $(e.target).val() if e.target.id is "users"
    @checklist_id = $(e.target).val() if e.target.id is "checklists"
    if e.target.id is "group_by"
      @group_by = $(e.target).val()

    window.location.hash = @link()
    e.preventDefault()

  on_change_month: (e) ->
    @pie_chart.counts = @counts[Number($(e.target).val())]
    @pie_chart.render()


  on_change_user_checkbox: (e) ->
    index = _.lastIndexOf(@user_ids, Number($(e.target).val()))
    if $(e.target).is(":checked")
      @timeline_chart.chart.showDataColumns(index)
    else
      @timeline_chart.chart.hideDataColumns(index)
#    for checkbox in @$(".user_checkbox:checked")
