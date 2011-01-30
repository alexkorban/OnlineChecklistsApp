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
      <h1>Reports</h1>
      <ul>
        <li><a href = "#timeline">Timeline</a></li>
        <li><a href = "#charts">Charts</a></li>
      </ul>
    ''')

    @render()


  render: ->
    $(@el).html(@template())


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
    console.log "rendering checklist", @el, @checklists
    $("#" + @id).replaceWith(@template({allow_all: @allow_all, checklists: @checklists}))
    #@el = $("#" + @id)[0]
    console.log "after", @el


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

    console.log(@users)
    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <h1>Reports &gt; Timeline</h1>
      <div class = "controls">
        <a href = "#<%= prev_week_link %>" class = "prev_week">Prev week</a>
        <% if (next_week_link != null) { %>
          <a href = "#<%= next_week_link %>" class = "next_week">Next week</a>
        <% } %>
        User:
        <select id = "users" class = "filter">
          <option value = "0"><%= all %></option>
          <% users.each(function(user) { %>
            <option value = "<%= user.id %>"><%= user.name() == null || user.name().length == 0 ? user.email() : user.name() %></option>
          <% }); %>
        </select>
        Checklist:
        <select id = "checklists"></select>
      </div>
      <% _.each(entries_by_day, function(entries, day) { %>
        <h2><%= day %></h2>
        <% _.each(entries, function(entry) { %>
          <%= entry["for"] %> <%= entry.user_name %> <%= entry.display_time %><br/>
        <% }); %>
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
    console.log("starting to render pie chart")
    google.load('visualization', '1', {'packages':['corechart'], callback: =>
      data = new google.visualization.DataTable()
      console.log "created data table"
      data.addColumn('string', 'Task')
      data.addColumn('number', 'Hours per Day')
      for i in [0...@user_ids.length]
        data.addRow([@users.get(@user_ids[i]).name(), @counts[i + 1]])
      console.log "added data"
      # Instantiate and draw our chart, passing in some options.
      console.log '_' + @id, document.getElementById('_' + @id)
      chart = new google.visualization.PieChart(document.getElementById('_' + @id))
      console.log "chart: ", chart
      chart.draw(data, {width: 400, height: 240, is3D: true, title: 'My Daily Activities'})
    })


class TimelineChart extends Backbone.View
  id: "timeline_chart"
  tagName: "div"

  constructor: (args) ->
    super
    @counts = args.counts
    @users = args.users
    @user_ids = args.user_ids

    #$("#" + @id).replaceWith(@el)


  render: =>
    console.log "starting to render timeline chart"

      # Load the Visualization API and the piechart package.
    google.load('visualization', '1', {'packages':['annotatedtimeline'], callback: =>
      data = new google.visualization.DataTable()
      data.addColumn('date', 'Date')
      for id in @user_ids
        data.addColumn('number', @users.get(id).name())
      data.addRows(@counts)

      chart = new google.visualization.AnnotatedTimeLine(document.getElementById(@id));
      chart.draw(data, {displayAnnotations: false});

    })



class root.ChartView extends Backbone.View
  tagName: "div"
  id: "content"
  events: {
    "change .filter": "on_change_filter"
    "change .month" : "on_change_month"
  }

  constructor: (args) ->
    super

    @users = args.users
    @checklists = args.checklists
    @users = args.users
    @checklist_id = args.checklist_id
    @all = "- All -"

    @checklist_dropdown = new ChecklistDropdown({id: "checklists", checklists: @checklists})
    @checklist_id = @checklists.at(0).id if !@checklist_id?

    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <h1>Reports &gt; Charts</h1>
      <div class = "controls">
        Checklist:
        <select id = "checklists"></select>
      </div>
      <div style = "text-align: top">
        <div id = "timeline_chart" style='width: 700px; height: 400px; display: inline-block'></div>
        <div id = "user_list" style  = "display: inline-block; min-height: 400px">
          <input type = "checkbox" value = "0" id = "checkbox_0" /><label for="checkbox_0"><%= all %></label><br/>
          <% console.log(users); %>
          <% _.each(users.models, function(user) { %>
            <input type = "checkbox" id = "checkbox_<%= user.id %>" /><label for="checkbox_<%= user.id %>"><%= user.name() %></label><br/>
          <% }); %>
        </div>
      </div>
      <div id = "pie_chart">
        <select class = "month">
          <% months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]; %>
          <% _.each(counts, function(count, index) { %>
            <option value = "<%= index %>"><%= months[count[0].getMonth()] + ' ' + String(count[0].getYear() + 1900) %></option>
          <% }); %>
        </select>
        <div id = "_pie_chart"></div>
      </div>
    ''')

    $.getJSON @counts_url(), (data, textStatus, xhr) =>
      @counts = data.counts #@type_cast(data.counts)
      for item in @counts
        item[0] = new Date(item[0])

      @totals = data.totals
      for item in @totals
        item[0] = new Date(item[0])

      @user_ids = data.user_ids

      @timeline_chart = new TimelineChart({counts: @counts, users: @users, user_ids: @user_ids})
      @pie_chart = new PieChart({users: @users, user_ids: @user_ids, counts: @counts[@counts.length - 1]})

      @render()


    #@$("#checklists").selectedIndex = 0


  render: ->
    $(@el).html(@template({checklists: @checklists, users: @users, counts: @counts, all: @all}))
    @checklist_dropdown.render()
    @timeline_chart.render()
    @pie_chart.render()
    @$("#checklists").val(@checklist_id)


  link: ->
    link = "charts"
    link += "/u0"
    link += "/c#{@checklist_id}"
    link


  counts_url: ->
    "/entries/counts?checklist_id=#{@checklist_id}"


  on_change_filter: (e) ->
    #@user_id = $(e.target).val() if e.target.id is "users"
    @checklist_id = $(e.target).val() if e.target.id is "checklists"
    window.location.hash = @link()
    e.preventDefault()

  on_change_month: (e) ->
    @pie_chart.counts = @counts[Number($(e.target).val())]
    @pie_chart.render()