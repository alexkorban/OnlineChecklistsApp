root = this


String::starts_with = (str) ->
  this.match("^" + str) == str


String::ends_with = (str) ->
  this.match(str + "$") == str


# add a chainable logging function to jQuery
jQuery.fn.log = (msg) ->
  console.log("%s: %o", msg, this)
  return this


root.append_fn = (fn, fn_to_append) ->
    if !fn?
    	return fn_to_append
    else
	    return ->
        fn()
        fn_to_append()


Backbone.emulateHTTP = true;    # use _method parameter instead of PUT and DELETE HTTP requests



class AppController extends Backbone.Controller
  routes:
    "": "checklists"
    "checklists": "checklists"
    "checklists/:cid/edit": "edit"
    "checklists/:cid": "show"
    "timezone": "timezone"
    "create": "create"
    "users": "users"
    "timeline": "timeline"
    "timeline/:week_offset/u:user_id/c:checklist_id": "timeline"
    "charts": "charts"
    "charts/c:checklist_id/g:group_by": "charts"

  constructor: ->
    super
    @flash = null


  get_flash: ->
    res = @flash
    @flash = null
    res

  checklists: ->
    if !current_account.time_zone? || current_account.time_zone.length == 0
      window.location.hash = "timezone"
    else
      @view = new ChecklistListView
      @saveLocation("checklists")


  timezone: ->
    @view = new TimeZoneView


  show: (cid) ->
    @view = new ChecklistView { model: Checklists.getByCid(cid) }
    @saveLocation("checklists/#{cid}")

  create: ->
    c = new Checklist
    Checklists.add(c)
    @view = new EditChecklistView { model: c }
    @saveLocation("create")


  edit: (cid) ->
    @view = new EditChecklistView { model: Checklists.getByCid(cid) }
    @saveLocation("checklists/#{cid}/edit")


  users: ->
    if current_user.role is "admin"
      @view = new UserPageView { users: Users }
      @saveLocation("users")


  timeline: (week_offset, user_id, checklist_id) ->
    @view = new TimelineView({week_offset: week_offset, users: Users, checklists: Checklists, user_id: user_id, checklist_id: checklist_id})
    @saveLocation("timeline")


  charts: (checklist_id, group_by)->
    checklist_id = Checklists.at(0).id if Checklists.length > 0 && !checklist_id?
    group_by = "day" if !group_by?
    @view = new ChartView({checklist_id: checklist_id, group_by: group_by, users: Users, checklists: Checklists})
    @saveLocation("charts")


#
# Start the app
#
heartbeat = ->
  $.ajax {
    url: "/heartbeat"
    dataType: "json"
    error: (xhr) ->
      # when an AJAX request is made after session timeout, Devise will do a 302 redirect to /users/sign_in,
      # resulting in a subsequent successful GET /users/sign_in; luckily for me though, the error handler
      # is fired in this situation, allowing to trigger a client side redirect to login page
      window.location.href = "/users/sign_in" if xhr.status == 200  # redirect to login page when Not Authorised code is returned
    }

$ ->
  window.app = new AppController()
  Backbone.history.start()
  #Backbone.history.saveLocation("checklists")
  setInterval(heartbeat, 5 * 60 * 1000)    # let the server know the session is active every 5 minutes

  # Enter key handler for ChecklistView;
  # Firefox requires it to be attached to document rather than "body"
  # IE9 doesn't work with keypress, only with keydown
  $(document).keydown (e) ->
    if e.keyCode != 13   # something other than Enter pressed
      return
      # 38 is up, 40 is down

    if $("#completion_message").is(":visible")
      # we can only get here if all items were complete at one point, so attempt to submit
      # note that some items could have been subsequently unchecked with the mouse, so the submission may still fail
      $(".complete").click()
      return

    if e.target.name == "notes" # Enter pressed on the Notes text field
      $(".checklist_item").not(".checked").first().toggleClass("selected").scrollintoview()
      $(e.target).blur()
      if $(".checklist_item").length == 0
        $("#completion_message").show()
      e.preventDefault();
      return

    # If we end up here, Enter was pressed somewhere other than the Notes text field

    last_selected = $(".checklist_item.selected")

    # next item to select (depending on whether something is already selected)
    next = if last_selected.length > 0 then last_selected.next(".checklist_item").not(".checked") else $(".checklist_item").not(".checked").first()

    last_selected.addClass("checked").removeClass("selected")
    if next.length > 0    # we aren't on the last item
      next.addClass("selected").scrollintoview()
      $("body").focus()
      e.preventDefault()
    else                  # we are on the last item
      if $(".checklist_item").not(".checked").length == 0   # everything is checked
        $("#completion_message").show()
        $("#incomplete_warning").hide()
        $(".complete").scrollintoview()
        e.preventDefault()


