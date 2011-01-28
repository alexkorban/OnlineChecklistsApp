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

  constructor: (week_offset, users, checklists) ->
    super
    @week_offset = if week_offset? then Number(week_offset) else 0
    @users = users
    @checklists = checklists

    @all = "- All -"


    console.log(@users)
    $("#" + @id).replaceWith(@el)

    @template = _.template('''
      <h1>Reports &gt; Timeline</h1>
      <div class = "controls">
        <a href = "#timeline-<%= Number(week_offset) + 1 %>" class = "prev_week">Prev week</a>
        <% if (week_offset > 0) { %>
          <a href = "#timeline-<%= Number(week_offset) - 1 %>" class = "next_week">Next week</a>
        <% } %>
        User:
        <select class = "users">
          <option><%= all %></option>
          <% users.each(function(user) { %>
            <option value = "<%= user.cid %>"><%= user.name() == null || user.name().length == 0 ? user.email() : user.name() %></option>
          <% }); %>
        </select>
        Checklist:
        <select class = "checklists">
          <option><%= all %></option>
          <% checklists.each(function(checklist) { %>
            <option value = "<%= checklist.cid %>"><%= checklist.name() %></option>
          <% }); %>
        </select>
      </div>
      <% _.each(entries_by_day, function(entries, day) { %>
        <h2><%= day %></h2>
        <% _.each(entries, function(entry) { %>
          <% console.log(day, ": ", entry); %>
          <%= entry["for"] %> <%= entry.user_name %> <%= entry.display_time %><br/>
        <% }); %>
      <% }); %>
    ''')

    $.getJSON "/entries/?week_offset=#{@week_offset}", (data, textStatus, xhr) =>
      @entries_by_day = data
      @render()

  render: ->
    $(@el).html(@template({all: @all, users: @users, checklists: @checklists, entries_by_day: @entries_by_day, week_offset: @week_offset}))