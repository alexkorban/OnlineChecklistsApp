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


class Chart extends Backbone.View
  id: "chart"
  tagName: "div"

  constructor: (args) ->
    super
    @checklist_id = args.checklist_id

    $("#" + @id).replaceWith(@el)
    console.log "el in constructor: ", @el


  counts_url: ->
    "/entries/counts?checklist_id=#{@checklist_id}"


  render: =>
    console.log "starting to render chart"
    $.getJSON @counts_url(), (data, textStatus, xhr) =>
      @counts = data
      # Load the Visualization API and the piechart package.
      google.load('visualization', '1', {'packages':['annotatedtimeline'], callback: =>
#        console.log("creating chart")
#        data = new google.visualization.DataTable()
#        console.log "created data table"
#        data.addColumn('string', 'Task')
#        data.addColumn('number', 'Hours per Day')
#        data.addRows([
#          ['Work', 11],
#          ['Eat', 2],
#          ['Commute', 2],
#          ['Watch TV', 2],
#          ['Sleep', 7]
#        ])
#        console.log "added data"
#        # Instantiate and draw our chart, passing in some options.
#        chart = new google.visualization.PieChart(document.getElementById('chart'))
#        console.log "chart: ", chart
#        chart.draw(data, {width: 400, height: 240, is3D: true, title: 'My Daily Activities'})
        data = new google.visualization.DataTable()
        data.addColumn('date', 'Date')
        data.addColumn('number', 'Sold Pencils')
        data.addColumn('number', 'Sold Pens')
        data.addRows([
          [new Date(2008, 1 ,1), 30000, 40645],
          [new Date(2008, 1 ,2), 14045, 20374],
          [new Date(2008, 1 ,3), 55022, 50766],
          [new Date(2008, 1 ,4), 75284, 14334],
          [new Date(2008, 1 ,5), 41476, 66467],
          [new Date(2008, 1 ,6), 33322, 39463]
        ])

        chart = new google.visualization.AnnotatedTimeLine(document.getElementById('chart'));
        chart.draw(data, {displayAnnotations: false});

      });



class root.ChartView extends Backbone.View
  tagName: "div"
  id: "content"
  events: {
    "change .filter": "on_change_filter"
  }

  constructor: (args) ->
    super

    @users = args.users
    @checklists = args.checklists
    @checklist_id = args.checklist_id
    @all = "- All -"

    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <h1>Reports &gt; Charts</h1>
      <div class = "controls">
        Checklist:
        <select id = "checklists"></select>
      </div>
      <div id = "chart" style='width: 700px; height: 240px;'></div>
    ''')

    @checklist_dropdown = new ChecklistDropdown({id: "checklists", checklists: @checklists})
    @checklist_id = @checklists.at(0).id if !@checklist_id?
    #@$("#checklists").selectedIndex = 0

    @chart = new Chart({checklist_id: @checklist_id})

    @render()

  render: ->
    $(@el).html(@template({checklists: @checklists, all: @all, chart_url: @chart_url()}))
    @checklist_dropdown.render()
    @chart.render()
    @$("#checklists").val(@checklist_id)


  chart_url: ->
    url = "http://aoteastudios.com/images/logo.png"


  link: ->
    link = "charts"
    link += "/u0"
    link += "/c#{@checklist_id}"
    link


  on_change_filter: (e) ->
    #@user_id = $(e.target).val() if e.target.id is "users"
    @checklist_id = $(e.target).val() if e.target.id is "checklists"
    window.location.hash = @link()
    e.preventDefault()
