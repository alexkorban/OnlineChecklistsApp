(function() {
  var ChecklistCollection, Entry, Item, ItemCollection, root;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  root = this;
  Item = (function() {
    __extends(Item, Backbone.Model);
    Item.prototype.defaults = {
      content: "New item"
    };
    function Item() {
      Item.__super__.constructor.apply(this, arguments);
    }
    Item.prototype.content = function() {
      return this.get("content");
    };
    return Item;
  })();
  ItemCollection = (function() {
    __extends(ItemCollection, Backbone.Collection);
    ItemCollection.prototype.model = Item;
    function ItemCollection() {
      ItemCollection.__super__.constructor.apply(this, arguments);
    }
    return ItemCollection;
  })();
  root.Checklist = (function() {
    __extends(Checklist, Backbone.Model);
    Checklist.prototype.defaults = {
      name: "New checklist"
    };
    function Checklist() {
      Checklist.__super__.constructor.apply(this, arguments);
      this.items = new ItemCollection;
      this.set_items_url();
    }
    Checklist.prototype.name = function() {
      return this.get("name");
    };
    Checklist.prototype.save = function() {
      this.set({
        items: this.items
      });
      return Checklist.__super__.save.apply(this, arguments);
    };
    Checklist.prototype.set_items_url = function() {
      return this.items.url = "/checklists/" + this.id;
    };
    return Checklist;
  })();
  ChecklistCollection = (function() {
    __extends(ChecklistCollection, Backbone.Collection);
    ChecklistCollection.prototype.model = Checklist;
    ChecklistCollection.prototype.url = "/checklists";
    function ChecklistCollection() {
      ChecklistCollection.__super__.constructor.apply(this, arguments);
    }
    return ChecklistCollection;
  })();
  Entry = (function() {
    __extends(Entry, Backbone.Model);
    Entry.prototype.url = "/entries";
    function Entry(args) {
      Entry.__super__.constructor.apply(this, arguments);
    }
    return Entry;
  })();
  root.Checklists = new ChecklistCollection;
  root.TimeZoneView = (function() {
    __extends(TimeZoneView, Backbone.View);
    TimeZoneView.prototype.tagName = "div";
    TimeZoneView.prototype.id = "content";
    function TimeZoneView() {
      TimeZoneView.__super__.constructor.apply(this, arguments);
      $("#" + this.id).replaceWith(this.el);
      $.get("/time_zone", __bind(function(data, textStatus, xhr) {
        console.log(data);
        this.template = _.template("Please set the time zone you are in:<br/><br/>\n" + data + "\n<br/><br/>This is necessary to get accurate reports.");
        return this.render();
      }, this));
    }
    TimeZoneView.prototype.render = function() {
      $(this.el).html(this.template());
      $("#heading").html("Set time zone");
      return this.$("#set_time_zone").attr("href", "#checklists");
    };
    return TimeZoneView;
  })();
  root.ChecklistListView = (function() {
    __extends(ChecklistListView, Backbone.View);
    ChecklistListView.prototype.tagName = "div";
    ChecklistListView.prototype.id = "content";
    ChecklistListView.prototype.events = {
      "click .create": "on_create",
      "click .delete": "on_delete",
      "dblclick li": "on_doubleclick",
      "click .confirm_delete": "on_confirm_delete",
      "click .cancel_delete": "on_cancel_delete"
    };
    function ChecklistListView() {
      ChecklistListView.__super__.constructor.apply(this, arguments);
      Checklists.refresh(Checklists.select(function(model) {
        return model.id != null;
      }));
      $("#" + this.id).replaceWith(this.el);
      this.template = _.template('<% if (flash != null) { %>\n  <div id = \'flash\' class = \'notice\'><div><%= flash %></div></div>\n<% } %>\n<% if (checklists.length == 0) { %>\n  <div>\n    It\'s time to create some checklists because you don\'t have any!<br/><br/>Press the <b>Create checklist</b> button below to create one.\n    <img src = "/images/down_32.png" style = "display: block; margin-left: 50px; margin-top: 10px" />\n  </div>\n<% } %>\n<ul class = "checklists">\n<% checklists.each(function(checklist) { %>\n<li class = "checklist" id = "<%= checklist.cid %>"><%= checklist.name() %>\n  <span class = "controls">\n    <a href="#checklists/<%= checklist.cid %>">Fill out</a> |\n    <a class = "secondary" href = "#checklists/<%= checklist.cid %>/edit">Edit</a> |\n    <a class = "secondary delete" id = "delete_<%= checklist.cid %>" href = "#">Delete</a>\n  </span>\n</li>\n<% }); %>\n</ul>\n<div class = "message" style = "display: none">\n  You\'ve reached the limit of your plan with <%= window.Plan.checklists %> checklists.\n  <% if (current_user.role == "admin") { %>\n    <a href = "/users/edit#plan">Please consider upgrading to a larger plan</a>.\n  <% } else { %>\n    Please ask the administrator of your account to upgrade to a larger plan.\n  <% } %>\n</div>\n<div style = "margin-top: <%= checklists.length > 0 ? 40 : 0 %>px">\n  <a class = "create button" href = "#">Create checklist</a>\n  <a class = "button" href = "#timeline">View reports</a>\n  <% if (current_user.role == "admin") { %> <a class = "button" href = "#users">Invite users</a> <% } %>\n</div>');
      this.render();
    }
    ChecklistListView.prototype.render = function() {
      $(this.el).html(this.template({
        checklists: Checklists,
        flash: window.app.get_flash()
      }));
      $("#heading").html("Checklists");
      return this.controls_contents = {};
    };
    ChecklistListView.prototype.on_create = function(e) {
      if (Checklists.length >= window.Plan.checklists) {
        this.$(".message").show();
      } else {
        window.location.hash = "create";
      }
      return e.preventDefault();
    };
    ChecklistListView.prototype.on_doubleclick = function(e) {
      return window.location.hash = "#checklists/" + e.target.id;
    };
    ChecklistListView.prototype.on_delete = function(e) {
      var cid, controls;
      console.log("on_delete");
      cid = e.target.id.substr(7);
      console.log(cid);
      controls = this.$(e.target).closest(".controls");
      console.log(controls);
      this.controls_contents[cid] = controls.html();
      controls.html("<b>Delete checklist?</b>\n<a class = 'confirm_delete' id = 'confirm_delete_" + cid + "' href = '#'>Delete</a> or\n<a class = 'cancel_delete' id = 'cancel_delete_" + cid + "' href = '#'>Cancel</a>");
      return e.preventDefault();
    };
    ChecklistListView.prototype.on_confirm_delete = function(e) {
      var checklist;
      checklist = Checklists.getByCid(e.target.id.substr(15));
      checklist.destroy();
      Checklists.remove(checklist);
      this.render();
      e.preventDefault();
      return e.stopPropagation();
    };
    ChecklistListView.prototype.on_cancel_delete = function(e) {
      var controls;
      controls = this.$(e.target).closest(".controls");
      console.log(this.controls_contents);
      console.log(e.target.id.substr(14));
      controls.html(this.controls_contents[e.target.id.substr(14)]);
      e.preventDefault();
      return e.stopPropagation();
    };
    return ChecklistListView;
  })();
  root.ChecklistView = (function() {
    __extends(ChecklistView, Backbone.View);
    ChecklistView.prototype.tagName = "div";
    ChecklistView.prototype.id = "content";
    ChecklistView.prototype.events = {
      "click .complete": "on_complete",
      "click .checklist_item": "on_click_item",
      "focus input": "on_focus_input",
      "blur input": "on_blur_input"
    };
    function ChecklistView() {
      ChecklistView.__super__.constructor.apply(this, arguments);
      this.template = _.template('<div class = "input_field">\n  For: <input name = "for" type = "text" />\n  <span class = "instructions">(press Enter to continue)</span>\n</div>\n<ul style = "margin-bottom: 40px; margin-top: 40px">\n<% items.each(function(item) { %>\n<li class = "checklist_item"><%= item.content() %><span class = "instructions">(press Enter to mark as done)</span></li>\n<% }); %>\n</ul>\n<div class = "message" id = "incomplete_warning" style = "display: none; margin-bottom: 20px">Please complete and check off all the items in the checklist first.</div>\n<div class = "message" id = "completion_warning" style = "display: none; margin-bottom: 20px">Press Enter to submit the checklist.</div>\n<button class = "complete">Complete!</button>\n<span style = "margin-left: 20px; margin-right: 10px">or</span>  <a href = "#checklists">Cancel</a>');
      $("#" + this.id).replaceWith(this.el);
      this.model.items.fetch({
        success: __bind(function() {
          return this.render();
        }, this)
      });
    }
    ChecklistView.prototype.render = function() {
      $(this.el).html(this.template({
        items: this.model.items
      }));
      $("#heading").html(this.model.name());
      return this.$("input[name='for']").focus();
    };
    ChecklistView.prototype.on_complete = function(e) {
      var entry;
      if (this.$(".checklist_item").not(".checked").length > 0) {
        this.$("#incomplete_warning").show();
        this.$("#completion_warning").hide();
        e.preventDefault();
        return;
      }
      entry = new Entry({
        checklist_id: this.model.id,
        "for": this.$("input[name=for]").val()
      });
      entry.save();
      current_account.has_entries = true;
      window.app.flash = "Completed checklist: " + (this.model.name());
      return window.location.hash = "checklists";
    };
    ChecklistView.prototype.on_click_item = function(e) {
      this.$(e.target).toggleClass("checked");
      if (this.$(".checklist_item").not(".checked").length === 0) {
        return this.$("#completion_warning").show();
      } else {
        return this.$("#completion_warning").hide();
      }
    };
    ChecklistView.prototype.on_keydown = function(e) {
      return console.log(e.keyCode);
    };
    ChecklistView.prototype.on_focus_input = function(e) {
      this.$(".checklist_item").removeClass("selected");
      return this.$(".input_field .instructions").show();
    };
    ChecklistView.prototype.on_blur_input = function(e) {
      return this.$(".input_field .instructions").hide();
    };
    return ChecklistView;
  })();
  root.EditItemView = (function() {
    __extends(EditItemView, Backbone.View);
    EditItemView.prototype.model = Item;
    EditItemView.prototype.tagName = "li";
    EditItemView.prototype.events = {
      "click .remove_item": "on_remove_item",
      "change input[type=text]": "on_change"
    };
    function EditItemView() {
      EditItemView.__super__.constructor.apply(this, arguments);
      this.template = _.template('<input type = "text" value = "<%= item.content() %>" /> <a href = "#" class = "remove_item">X</a>');
    }
    EditItemView.prototype.render = function() {
      $(this.el).html(this.template({
        item: this.model
      }));
      return $(this.el);
    };
    EditItemView.prototype.on_remove_item = function(e) {
      this.collection.remove(this.model);
      e.preventDefault();
      return e.stopPropagation();
    };
    EditItemView.prototype.on_change = function(e) {
      return this.model.set({
        "content": $(e.target).val()
      });
    };
    return EditItemView;
  })();
  root.EditChecklistView = (function() {
    __extends(EditChecklistView, Backbone.View);
    EditChecklistView.prototype.events = {
      "click .save": "on_save",
      "click .add_item": "on_add_item"
    };
    EditChecklistView.prototype.tagName = "div";
    EditChecklistView.prototype.id = "content";
    function EditChecklistView() {
      this.add_items = __bind(this.add_items, this);;
      this.add_item = __bind(this.add_item, this);;      EditChecklistView.__super__.constructor.apply(this, arguments);
      this.template = _.template('Checklist: <input type = "text" class = "checklist_name" value = "<%= name %>" /><br/><br/>\n<ul>\n</ul>\n<ul><li><a class = "button add_item" href = "#">Add step</a></li></ul>\n<br/>\n<br/>\n<a class = "button save" href = "#checklists">Save checklist</a>\n<span style = "margin-left: 20px; margin-right: 10px">or</span>  <a href = "#checklists">Cancel</a>');
      this.model.items.bind("add", this.add_item);
      this.model.items.bind("remove", this.remove_item);
      this.model.items.bind("refresh", this.add_items);
      $("#" + this.id).replaceWith(this.el);
      this.render();
      this.item_el = $(this.el).find("ul:first");
      if (this.model.id != null) {
        this.model.items.fetch();
      } else {
        this.model.items.refresh([new Item, new Item, new Item]);
      }
    }
    EditChecklistView.prototype.on_save = function(e) {
      this.model.set({
        "name": this.$(".checklist_name").val()
      });
      this.model.save({}, {
        success: __bind(function(model, response) {
          this.model.set_items_url();
          return window.location.hash = $(e.target).attr("href");
        }, this)
      });
      return e.preventDefault();
    };
    EditChecklistView.prototype.on_add_item = function(e) {
      this.model.items.add();
      e.preventDefault();
      return e.stopPropagation();
    };
    EditChecklistView.prototype.render = function() {
      $(this.el).html(this.template({
        name: this.model.name(),
        items: this.model.items
      }));
      return $("#heading").html("Create checklist");
    };
    EditChecklistView.prototype.add_item = function(item) {
      var view;
      view = new EditItemView({
        model: item,
        collection: this.model.items
      });
      item.view = view;
      return this.item_el.append(view.render());
    };
    EditChecklistView.prototype.add_items = function() {
      return this.model.items.each(this.add_item);
    };
    EditChecklistView.prototype.remove_item = function(item) {
      return item.view.remove();
    };
    return EditChecklistView;
  })();
}).call(this);
