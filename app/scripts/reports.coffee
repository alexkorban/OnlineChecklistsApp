root = this

class Report extends Backbone.Model
  constructor: ->
    super


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
          <a href = "#<%= prev_week_link %>" style = "border: none"><img src = "/images/left_32.png" /></a>
          <a href = "#<%= prev_week_link %>">Prev week</a>
        </div>
        <% if (next_week_link != null) { %>
          <div class = "next_week">
            <a href = "#<%= next_week_link %>">Next week</a>
            <a href = "#<%= next_week_link %>" style = "border: none"><img src = "/images/right_32.png" /></a>
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
        <a class = "button" style = "margin-left: 40px" href = "#charts">Chart view</a>
      </div>
      <% _.each(entries_by_day, function(day_entry) { %>
        <h2><%= day_entry[0] %></h2>
        <table class = "timeline_entries">
          <tr>
            <th>Checklist</th>
            <th>User</th>
            <th>Completed at</th>
            <th>Completed for</th>
          </tr>

          <% _.each(day_entry[1], function(entry) { %>
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
    @colors = args.colors
    @first_render = yes

    #$("#" + @id).replaceWith(@el)


  render: =>

      # Load the Visualization API and the piechart package.
    google.load('visualization', '1', {'packages':['annotatedtimeline'], callback: =>
      data = new google.visualization.DataTable()
      data.addColumn('date', 'Date')
      for id in @user_ids
        data.addColumn('number', if id is 0 then "All users" else @users.get(id).name())
      data.addRows(@counts)

      @chart = new google.visualization.AnnotatedTimeLine(document.getElementById(@id));
      @chart.draw(data, {
        displayAnnotations: no
        colors: @colors
        displayZoomButtons: no
        thickness: 2
        });
      if @first_render
        for i in [0...@user_ids.length - 1]
          @chart.hideDataColumns(i)
        @first_render = no
    })


class root.ChartView extends Backbone.View
  tagName: "div"
  id: "content"
  events: {
    "change .filter": "on_change_filter"
    "change .user_checkbox" : "on_change_user_checkbox"
  }
  colors: [
    "#669999", "#99CC00", "#330000", "#FF9900", "#996666"
    "#990033", "#003399", "#9999CC", "#FFCC66", "#666600"
    "#9933CC", "#996633", "#666633", "#009900", "#33CC99",
    "#0099CC", "#333399", "#CC99CC", "#000099", "#66CCFF",
  ]

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
        <a class = "button" style = "margin-left: 40px" href = "#timeline">Timeline view</a>
      </div>
      <div class = "daily" style = "padding-top: 20px">Note: daily counts are only available for the last 30 days</divS>
      <table style = "margin-top: 20px">
        <tr>
          <td>
            <div id = "timeline_chart" style='width: 700px; height: 400px; display: inline-block'></div>
          </td>
          <td style = "padding-left: 20px; vertical-align: top">
            <input type = "checkbox" class = "user_checkbox" value = "0" id = "checkbox_0" checked = "checked" />
            <label for="checkbox_0" style = "color: <%= colors[_.lastIndexOf(user_ids, 0)] %>">All users</label><br/>
            <% _.each(users.models, function(user, index) { %>
              <input type = "checkbox" class = "user_checkbox" id = "checkbox_<%= user.id %>" value = "<%= user.id %>" />
              <label for="checkbox_<%= user.id %>" style = "color: <%= colors[_.lastIndexOf(user_ids, user.id)] %>"><%= user.name() %></label><br/>
            <% }); %>
          </td>
        </tr>
      </table>
      <table>
      <tr>
      <% _.each(colors, function(color) { %>
        <td style = "background-color: <%= color %>">&nbsp;</td>
      <% }); %>
      </tr></table>
    ''')

    $.getJSON @counts_url(), (data, textStatus, xhr) =>
      @counts = data.counts #@type_cast(data.counts)

      if @counts.length > 0
        for item in @counts
          item[0] = new Date(item[0])

        @user_ids = data.user_ids

        @timeline_chart = new TimelineChart({counts: @counts, users: @users, user_ids: @user_ids, colors: @colors})

      @render()


    #@$("#checklists").selectedIndex = 0


  render: ->
    $(@el).html(@template({checklists: @checklists, users: @users, user_ids: @user_ids, counts: @counts, all: @all, colors: @colors}))
    $("#heading").html("Reports &gt; Charts")
    @checklist_dropdown.render()
    if @counts.length > 0
      @timeline_chart.render()
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


  on_change_user_checkbox: (e) ->
    index = _.lastIndexOf(@user_ids, Number($(e.target).val()))
    if $(e.target).is(":checked")
      @timeline_chart.chart.showDataColumns(index)
    else
      @timeline_chart.chart.hideDataColumns(index)
#    for checkbox in @$(".user_checkbox:checked")
