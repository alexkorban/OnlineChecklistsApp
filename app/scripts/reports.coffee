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
        <% _.each(checklists, function(checklist) { %>
          <option value = "<%= checklist.id %>"><%= checklist.name %></option>
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

    @all = "- All -"

    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <div id = "buttons">
        <a class = "button" href = "#checklists">Go to checklists</a>
        <a class = "button" href = "#charts">View charts</a>
      </div>
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
            <% _.each(users, function(user) { %>
              <option value = "<%= user.id %>"><%= user.name == null || user.name.length == 0 ? user.email : user.name %></option>
            <% }); %>
          </select>
        </div>
        Checklist:
        <select id = "checklists"></select>
      </div>
      <% if (entries_by_day.length == 0) { %>
        <h2>No entries for this week</h2>
      <% } %>
    ''')

    @day_entry_template = _.template '''
        <h2><%= day_entry[0] %></h2>
        <table class = "timeline_entries" style = "width: 100%">
          <tr>
            <th style = "width: 40%">Checklist</th>
            <th style = "width: 10%">User</th>
            <th style = "width: 15%">Completed at</th>
            <th style = "width: 35%">Completed for</th>

          </tr>
        </table>
    '''

    @day_entry_row_template = _.template '''
      <tr>
        <td style = "width: 40%" class = "first"><%= row.checklist_name %></td>
        <td style = "width: 10%"><%= row.user_name %></td>
        <td style = "width: 15%"><%= row.display_time %></td>
        <td style = "width: 35%"><%= row.notes %></td>
      </tr>
    '''
    @no_entries_template = _.template '''
      You'll need to
      <% if (checklists.length == 0) { %>
        <a href = "#checklists">define some checklists</a> and get people to fill them out
      <% } else { %>
        define some checklists and <a href = "#checklists">get people to fill them out</a>
      <% } %>
      to get reports and charts like this:<br/><br/>
      <img src = "/images/timeline-sample.png" /><br/>
      <img src = "/images/chart-sample.png" /><br/>
    '''

    @checklist_id = if args.checklist_id? then args.checklist_id else 0

    $.ajax {
      url: @entries_url(),
      dataType: 'json',
      success: (data, textStatus, xhr) =>
        @entries_by_day = data.entries
        @entries_checklists = data.checklists
        @users = data.users
        @checklist_dropdown = new ChecklistDropdown({id: "checklists", checklists: @entries_checklists, allow_all: yes})
        @render()
      error: (xhr) =>
        @render()         # entries_by_day will be undefined, causing the view to show instructions about creating some checklists and entries
    }
  render: ->
    $("#heading").html("Reports &gt; Timeline")
    document.title = "OnlineChecklists: Reports > Timeline"
    if @entries_by_day?   # entries_by_day will be undefined when the server returned an error, indicating that the account has no entries
      $(@el).html @template({
        all: @all
        users: @users
        entries_by_day: @entries_by_day
        next_week_link: @next_week_link()
        prev_week_link: @prev_week_link()
        })
      for day_entry in @entries_by_day
        $(@el).append(@day_entry_template({day_entry: day_entry}))
        for row in day_entry[1]
          @$(".timeline_entries:last").append(@day_entry_row_template({row: row}))

      @checklist_dropdown.render()
      @$("#users").val(@user_id) if @user_id
      @$("#checklists").val(@checklist_id) if @checklist_id
    else
      $(@el).html @no_entries_template({
        users: @users
        checklists: @checklists
      })


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


  render: =>
    google.load('visualization', '1', {'packages':['corechart'], callback: =>
      data = new google.visualization.DataTable()
      data.addColumn('string', 'Task')
      data.addColumn('number', 'Hours per Day')
      for i in [0...@users.length - 1]
        data.addRow([(if @users[i][0] is 0 then "Total" else @users[i][1]), @counts[i + 1]])
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
    @colors = args.colors
    @first_render = yes

    #$("#" + @id).replaceWith(@el)


  render: =>

      # Load the Visualization API and the piechart package.
    google.load('visualization', '1', {'packages':['annotatedtimeline'], callback: =>
      data = new google.visualization.DataTable()
      data.addColumn('date', 'Date')
      for user in @users
        data.addColumn('number', user.name)
      data.addRows(@counts)

      @chart = new google.visualization.AnnotatedTimeLine(document.getElementById(@id));
      @chart.draw(data, {
        displayAnnotations: no
        colors: @colors
        displayZoomButtons: no
        thickness: 2
        });
      if @first_render
        for i in [1...@users.length]    # the first data column (All users) is left visible
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
    @checklist_id = args.checklist_id
    @group_by = args.group_by
    @all = "- All -"
    @group_by = "day" if !@group_by?

    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <div id = "buttons">
        <a class = "button" href = "#checklists">Go to checklists</a>
        <a class = "button" href = "#timeline">View timeline</a>
      </div>
      <div class = "report_controls">
        Checklist:
        <select id = "checklists"></select>
        <span style = "padding-left: 40px">Totals:</span>
        <select id = "group_by" class = "filter">
          <option value = "day">Daily</option>
          <option value = "week">Weekly</option>
          <option value = "month">Monthly</option>
        </select>
      </div>
      <div id = "daily_message" style = "padding-top: 20px">
        Note: daily counts are only available for the last 30 days
      </div>
      <table style = "margin-top: 20px">
        <tr>
          <td>
            <div id = "timeline_chart" style='width: 700px; height: 350px; display: inline-block'></div>
          </td>
          <td style = "padding-left: 20px; vertical-align: top">
            <% _.each(users, function(user, index) { %>
              <input type = "checkbox" class = "user_checkbox" id = "checkbox_<%= user.id %>" value = "<%= user.id %>"
               <% if (user.id == 0) { %> checked = "checked" <% } %>
              />
              <label for="checkbox_<%= user.id %>" style = "color: <%= colors[_.lastIndexOf(users, user)] %>"><%= user.name %></label><br/>
            <% }); %>
          </td>
        </tr>
      </table>
    ''')

    $.getJSON @counts_url(), (data, textStatus, xhr) =>
      @counts = data.counts #@type_cast(data.counts)
      @count_users = data.users
      @count_checklists = data.checklists

      if @counts.length > 0
        for item in @counts
          # it might be tempting to try item[0] = new Date(item[0]) but that doesn't work in IE (why of course!)
          date_parts = item[0].split("-")
          item[0] = new Date(date_parts[0], date_parts[1] - 1, date_parts[2])

      @checklist_dropdown = new ChecklistDropdown({id: "checklists", checklists: @count_checklists})
      @checklist_id = @count_checklists.at(0).id if @count_checklists.length > 0 && !@checklist_id?

      @timeline_chart = new TimelineChart({counts: @counts, users: @count_users, colors: @colors})

      @render()


    #@$("#checklists").selectedIndex = 0


  render: ->
    $(@el).html(@template({checklists: @checklists, users: @count_users, counts: @counts, all: @all, colors: @colors, group_by: @group_by}))
    $("#heading").html("Reports &gt; Charts")
    document.title = "OnlineChecklists: Reports > Charts"
    @checklist_dropdown.render()
    $("#daily_message").hide() if @group_by != "day"
    if @counts.length > 0
      @timeline_chart.render()
    else
      @$("#timeline_chart").html("<b>No data available</b>")
    @$("#checklists").val(@checklist_id)
    @$("#group_by").val(@group_by)


  link: ->
    link = "charts"
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
    _.each @count_users, (user, index) =>
      if user.id == Number($(e.target).val())
        if $(e.target).is(":checked")
          @timeline_chart.chart.showDataColumns(index)
        else
          @timeline_chart.chart.hideDataColumns(index)

