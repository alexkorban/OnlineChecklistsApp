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
    @user_id = args.user_id
    @checklist_id = args.checklist_id

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
        <select id = "checklists" class = "filter">
          <option value = "0"><%= all %></option>
          <% checklists.each(function(checklist) { %>
            <option value = "<%= checklist.id %>"><%= checklist.name() %></option>
          <% }); %>
        </select>
      </div>
      <% _.each(entries_by_day, function(entries, day) { %>
        <h2><%= day %></h2>
        <% _.each(entries, function(entry) { %>
          <%= entry["for"] %> <%= entry.user_name %> <%= entry.display_time %><br/>
        <% }); %>
      <% }); %>
    ''')

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
