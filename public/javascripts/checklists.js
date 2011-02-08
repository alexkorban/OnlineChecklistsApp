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
  root.ChecklistListView = (function() {
    __extends(ChecklistListView, Backbone.View);
    ChecklistListView.prototype.events = {
      "click .remove": "on_remove"
    };
    function ChecklistListView() {
      ChecklistListView.__super__.constructor.apply(this, arguments);
      this.parent = $("#content");
      this.template = _.template('<ul>\n<% checklists.each(function(checklist) { %>\n<li><a href="#checklists/<%= checklist.cid %>"><%= checklist.name() %></a>\n  (<a href = "#checklists/<%= checklist.cid %>/edit">Edit</a> | <a id = "remove_<%= checklist.cid %>" class = "remove" href = "#">X</a>)</li>\n<% }); %>\n</ul>\n<a class = "button" href = "#create">Create new list</a>\n<a class = "button" href = "#reports">View reports</a>\n<% if (current_user.role == "admin") { %> <a class = "button" href = "#users">Invite users</a> <% } %>');
      this.render();
    }
    ChecklistListView.prototype.render = function() {
      $(this.el).html(this.template({
        checklists: Checklists
      }));
      $("#heading").html("Checklists");
      return this.parent.html("").append(this.el);
    };
    ChecklistListView.prototype.on_remove = function(e) {
      var checklist;
      console.log("cid = ", e.target.id.substr(7));
      checklist = Checklists.getByCid(e.target.id.substr(7));
      checklist.destroy();
      Checklists.remove(checklist);
      this.render();
      e.preventDefault();
      return e.stopPropagation();
    };
    return ChecklistListView;
  })();
  root.ChecklistView = (function() {
    __extends(ChecklistView, Backbone.View);
    ChecklistView.prototype.events = {
      "click .complete": "on_complete"
    };
    function ChecklistView() {
      ChecklistView.__super__.constructor.apply(this, arguments);
      this.parent = $("#content");
      this.template = _.template('For: <input name = "for" type = "text" />\n<ul>\n<% items.each(function(item) { %>\n<li><a href="#items-<%= item.cid %>"><%= item.content() %></a></li>\n<% }); %>\n</ul>\n<button class = "complete">Complete!</button>');
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
      return this.parent.html("").append(this.el);
    };
    ChecklistView.prototype.on_complete = function(e) {
      var entry;
      entry = new Entry({
        checklist_id: this.model.id,
        "for": this.$("input[name=for]").val()
      });
      return entry.save();
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
      "click .add_item": "on_add_item",
      "change .checklist_name": "on_change"
    };
    EditChecklistView.prototype.tagName = "div";
    EditChecklistView.prototype.id = "edit";
    function EditChecklistView() {
      this.add_items = __bind(this.add_items, this);;
      this.add_item = __bind(this.add_item, this);;      EditChecklistView.__super__.constructor.apply(this, arguments);
      this.parent = $("#content");
      this.template = _.template('Checklist: <input type = "text" class = "checklist_name" value = "<%= name %>" /><br/><br/>\n<ul>\n</ul>\n<ul><li><a class = "button add_item" href = "#">Add step</a></li></ul>\n<br/>\n<br/>\n<a class = "button save" href = "#checklists">Save checklist</a>\n<span style = "margin-left: 20px; margin-right: 10px">or</span>  <a href = "#checklists">Cancel</a>');
      this.model.items.bind("add", this.add_item);
      this.model.items.bind("remove", this.remove_item);
      this.model.items.bind("refresh", this.add_items);
      this.render();
      this.item_el = $(this.el).find("ul:first");
      if (this.model.id != null) {
        this.model.items.fetch();
      } else {
        this.model.items.refresh([new Item, new Item, new Item]);
      }
    }
    EditChecklistView.prototype.on_save = function(e) {
      return this.model.save({}, {
        success: __bind(function(model, response) {
          console.log("checklist id after save: ", this.model.id);
          return this.model.set_items_url();
        }, this)
      });
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
      $("#heading").html("Create checklist");
      return $(this.parent).html("").append(this.el);
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
    EditChecklistView.prototype.on_change = function(e) {
      return this.model.set({
        "name": $(e.target).val()
      });
    };
    return EditChecklistView;
  })();
}).call(this);
