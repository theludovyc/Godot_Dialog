tool
extends HSplitContainer

var editor_reference
var timeline_name: String = ''
var timeline_file: String = ''
var current_timeline:Dictionary
var current_events:Array

onready var master_tree = get_node('../MasterTreeContainer/MasterTree')
onready var timeline_node = $TimelineArea/TimeLine
onready var events_warning = $ScrollContainer/EventContainer/EventsWarning

var hovered_item = null
var selected_style : StyleBoxFlat = load("res://addons/dialogic/Editor/Events/styles/selected_styleboxflat.tres")
var selected_style_text : StyleBoxFlat = load("res://addons/dialogic/Editor/Events/styles/selected_styleboxflat_text_event.tres")
var selected_style_template : StyleBoxFlat = load("res://addons/dialogic/Editor/Events/styles/selected_styleboxflat_template.tres")
var saved_style : StyleBoxFlat
var selected_items : Array = []

var event_scenes : Dictionary = {}

var moving_piece = null
var piece_was_dragged = false

var batches = []
var building_timeline = true
signal selection_updated
signal batch_loaded


func _ready():
	var modifier = ''
	var _scale = get_constant("inspector_margin", "Editor")
	_scale = _scale * 0.125
	$ScrollContainer.rect_min_size.x = 180
	if _scale == 1.25:
		modifier = '-1.25'
		$ScrollContainer.rect_min_size.x = 200
	if _scale == 1.5:
		modifier = '-1.25'
		$ScrollContainer.rect_min_size.x = 200
	if _scale == 1.75:
		modifier = '-1.25'
		$ScrollContainer.rect_min_size.x = 390
	if _scale == 2:
		modifier = '-2'
		$ScrollContainer.rect_min_size.x = 390
	
	# We connect all the event buttons to the event creation functions
	for b in $ScrollContainer/EventContainer.get_children():
		if b is Button:
			if b.name == 'Question':
				b.connect('pressed', self, "_on_ButtonQuestion_pressed", [])
			elif b.name == 'Condition':
				b.connect('pressed', self, "_on_ButtonCondition_pressed", [])
			else:
				b.connect('pressed', self, "_create_event_button_pressed", [b.name])
	
	var style = $TimelineArea.get('custom_styles/bg')
	style.set('bg_color', get_color("dark_color_1", "Editor"))

# handles dragging/moving of events
func _process(delta):
	if moving_piece != null:
		var current_position = get_global_mouse_position()
		var node_position = moving_piece.rect_global_position.y
		var height = get_block_height(moving_piece)
		var up_offset = get_block_height(get_block_above(moving_piece))
		var down_offset = get_block_height(get_block_below(moving_piece))
		if up_offset != null:
			up_offset = (up_offset / 2) + 5
			if current_position.y < node_position - up_offset:
				move_block(moving_piece, 'up')
				piece_was_dragged = true
		if down_offset != null:
			down_offset = height + (down_offset / 2) + 5
			if current_position.y > node_position + down_offset:
				move_block(moving_piece, 'down')
				piece_was_dragged = true

# SIGNAL handles input on the events mainly for selection and moving events
func _on_event_block_gui_input(event, item: Node):
	if event is InputEventMouseButton and event.button_index == 1:
		if (not event.is_pressed()):
			if (not piece_was_dragged and moving_piece != null):
				pass
			if (moving_piece != null):
				indent_events()
			moving_piece = null
		elif event.is_pressed():
			moving_piece = item
			if not _is_item_selected(item):
				
				piece_was_dragged = true
			else:
				piece_was_dragged = false
			select_item(item)


## *****************************************************************************
##					 	SHORTCUTS
## *****************************************************************************


func _input(event):
	# some shortcuts need to get handled in the common input event
	# especially CTRL-based
	# because certain godot controls swallow events (like textedit)
	# we protect this with is_visible_in_tree to not 
	# invoke a shortcut by accident
	if get_focus_owner() is TextEdit:
		return
		
	if (event is InputEventKey and event is InputEventWithModifiers and is_visible_in_tree()):
		# CTRL UP
		if (event.pressed
			and event.alt == false
			and event.shift == false
			and event.control == false
			and event.scancode == KEY_UP
			and event.echo == false
		):
			# select previous
			if (len(selected_items) == 1):
				var prev = max(0, selected_items[0].get_index() - 1)
				var prev_node = timeline_node.get_child(prev)
				if (prev_node != selected_items[0]):
					selected_items = []
					select_item(prev_node)
				get_tree().set_input_as_handled()

			
		# CTRL DOWN
		if (event.pressed
			and event.alt == false
			and event.shift == false
			and event.control == false
			and event.scancode == KEY_DOWN
			and event.echo == false
		):
			# select next
			if (len(selected_items) == 1):
				var next = min(timeline_node.get_child_count() - 1, selected_items[0].get_index() + 1)
				var next_node = timeline_node.get_child(next)
				if (next_node != selected_items[0]):
					selected_items = []
					select_item(next_node)
				get_tree().set_input_as_handled()
			
		# CTRL DELETE
		if (event.pressed
			and event.alt == false
			and event.shift == false
			and event.control == false
			and event.scancode == KEY_DELETE
			and event.echo == false
		):
			if (len(selected_items) != 0):
				delete_selected_events()
				get_tree().set_input_as_handled()
			
		# CTRL T
		if (event.pressed
			and event.alt == false
			and event.shift == false
			and event.control == true
			and event.scancode == KEY_T
			and event.echo == false
		):
			var new_text = create_event0("TextEvent")
			select_item(new_text, false)
			indent_events()
			get_tree().set_input_as_handled()
			
		# CTRL A
		if (event.pressed
			and event.alt == false
			and event.shift == false
			and event.control == true
			and event.scancode == KEY_A
			and event.echo == false
		):
			if (len(selected_items) != 0):
				select_all_items()
			get_tree().set_input_as_handled()
		
		# CTRL SHIFT A
		if (event.pressed
			and event.alt == false
			and event.shift == true
			and event.control == true
			and event.scancode == KEY_A
			and event.echo == false
		):
			if (len(selected_items) != 0):
				deselect_all_items()
			get_tree().set_input_as_handled()
		
		# CTRL C
		if (event.pressed
			and event.alt == false
			and event.shift == false
			and event.control == true
			and event.scancode == KEY_C
			and event.echo == false
		):
			copy_selected_events()
			get_tree().set_input_as_handled()
		
		# CTRL V
		if (event.pressed
			and event.alt == false
			and event.shift == false
			and event.control == true
			and event.scancode == KEY_V
			and event.echo == false
		):
			paste_events()
			get_tree().set_input_as_handled()
		
		# CTRL X
		if (event.pressed
			and event.alt == false
			and event.shift == false
			and event.control == true
			and event.scancode == KEY_X
			and event.echo == false
		):
			cut_selected_events()
			get_tree().set_input_as_handled()

		# CTRL D
		if (event.pressed
			and event.alt == false
			and event.shift == false
			and event.control == true
			and event.scancode == KEY_D
			and event.echo == false
		):
			
			if len(selected_items) > 0:
				copy_selected_events()
				selected_items = [selected_items[-1]]
				paste_events()
			get_tree().set_input_as_handled()

func _unhandled_key_input(event):
	if (event is InputEventWithModifiers):
		# ALT UP
		if (event.pressed
			and event.alt == true 
			and event.shift == false 
			and event.control == false 
			and event.scancode == KEY_UP
			and event.echo == false
		):
			# move selected up
			if (len(selected_items) == 1):
				move_block(selected_items[0], "up")
				indent_events()
				get_tree().set_input_as_handled()
			
		# ALT DOWN
		if (event.pressed
			and event.alt == true 
			and event.shift == false 
			and event.control == false 
			and event.scancode == KEY_DOWN
			and event.echo == false
		):
			# move selected down
			if (len(selected_items) == 1):
				move_block(selected_items[0], "down")
				indent_events()
				get_tree().set_input_as_handled()

## *****************************************************************************
##					 	DELETING, COPY, PASTE
## *****************************************************************************

func delete_selected_events():
	if len(selected_items) == 0:
		return
	
	# get next element
	var next = min(timeline_node.get_child_count() - 1, selected_items[-1].get_index() + 1)
	var next_node = timeline_node.get_child(next)
	if _is_item_selected(next_node):
		next_node = null
	
	for event in selected_items:
		event.get_parent().remove_child(event)
		event.queue_free()
	
	# select next
	if (next_node != null):
		select_item(next_node, false)
	else:
		if (timeline_node.get_child_count() > 0):
			next_node = timeline_node.get_child(max(0, timeline_node.get_child_count() - 1))
			if (next_node != null):
				select_item(next_node, false)
		else:
			deselect_all_items()
	
	indent_events()

func cut_selected_events():
	copy_selected_events()
	delete_selected_events()

func copy_selected_events():
	if len(selected_items) == 0:
		return
	var event_copy_array = []
	for item in selected_items:
		event_copy_array.append(item.event_data)
	
	OS.clipboard = JSON.print(
		{
			"events":event_copy_array,
			"dialogic_version": editor_reference.version_string,
			"project_name": ProjectSettings.get_setting("application/config/name")
		})

func paste_events():
	var clipboard_parse = JSON.parse(OS.clipboard).result
	
	if typeof(clipboard_parse) == TYPE_DICTIONARY:
		if clipboard_parse.has("dialogic_version"):
			if clipboard_parse['dialogic_version'] != editor_reference.version_string:
				print("[D] Be careful when copying from older versions!")
		if clipboard_parse.has("project_name"):
			if clipboard_parse['project_name'] != ProjectSettings.get_setting("application/config/name"):
				print("[D] Be careful when copying from another project!")
		if clipboard_parse.has('events'):
			var event_list = clipboard_parse['events']
			if len(selected_items) > 0:
				event_list.invert()
			
			var new_items = []
			for item in event_list:
				if typeof(item) == TYPE_DICTIONARY and item.has('event_id'):
					new_items.append(load_event(item))
			selected_items = new_items
			sort_selection()
			visual_update_selection()
			indent_events()


## *****************************************************************************
##					 	BLOCK SELECTION
## *****************************************************************************

func _is_item_selected(item: Node):
	return item in selected_items

func select_item(item: Node, multi_possible:bool = true):
	if item == null:
		return

	if Input.is_key_pressed(KEY_CONTROL) and multi_possible:
		# deselect the item if it is selected
		if _is_item_selected(item):
			selected_items.erase(item)
		else:
			selected_items.append(item)
	elif Input.is_key_pressed(KEY_SHIFT) and multi_possible:
		
		if len(selected_items) == 0:
			selected_items = [item]
		else:
			var index = selected_items[-1].get_index()
			var goal_idx = item.get_index()
			while true:
				if index < goal_idx: index += 1
				else: index -= 1
				if not timeline_node.get_child(index) in selected_items:
					selected_items.append(timeline_node.get_child(index))
				
				if index == goal_idx:
					break
	else:
		if len(selected_items) == 1:
			if _is_item_selected(item):
				selected_items.erase(item)
			else:
				selected_items = [item]
		else:
			selected_items = [item]
	
	sort_selection()
	
	visual_update_selection()

# checks all the events and sets their styles (selected/deselected)
func visual_update_selection():
	for item in timeline_node.get_children():
		item.visual_deselect()
	for item in selected_items:
		item.visual_select()

## Sorts the selection using 'custom_sort_selection'
func sort_selection():
	selected_items.sort_custom(self, 'custom_sort_selection')

## Compares two event blocks based on their position in the timeline_node
func custom_sort_selection(item1, item2):
	return item1.get_index() < item2.get_index()

## Helpers
func select_all_items():
	selected_items = []
	for event in timeline_node.get_children():
		selected_items.append(event)
	visual_update_selection()

func deselect_all_items():
	selected_items = []
	visual_update_selection()

## *****************************************************************************
##				SPECIAL BLOCK OPERATIONS
## *****************************************************************************

# SIGNAL handles the actions of the small menu on the right
func _on_event_options_action(action: String, item: Node):
	### WORK TODO
	if action == "remove":
		if len(selected_items) != 1 or (len(selected_items) == 1 and selected_items[0] != item):
			select_item(item, false)
		delete_selected_events()
	else:
		move_block(item, action)
	indent_events()

func delete_event(event):
	event.get_parent().remove_child(event)
	event.queue_free()

## *****************************************************************************
##				CREATING NEW EVENTS USING THE BUTTONS
## *****************************************************************************

# Event Creation signal for buttons
func _create_event_button_pressed(button_name):
	select_item(create_event0(button_name))
	
	indent_events()
	
	editor_reference.need_save()

# the Question button adds multiple blocks 
func _on_ButtonQuestion_pressed() -> void:
	if len(selected_items) != 0:
		# Events are added bellow the selected node
		# So we must reverse the adding order
		create_event1(DialogicSingleton.Event_Type.EndBranch)
		create_event1(DialogicSingleton.Event_Type.Choice)
		create_event1(DialogicSingleton.Event_Type.Choice)
		create_event1(DialogicSingleton.Event_Type.Question)
	else:
		create_event1(DialogicSingleton.Event_Type.Question)
		create_event1(DialogicSingleton.Event_Type.Choice)
		create_event1(DialogicSingleton.Event_Type.Choice)
		create_event1(DialogicSingleton.Event_Type.EndBranch)
	
	indent_events()
	
	editor_reference.need_save()

# the Condition button adds multiple blocks 
func _on_ButtonCondition_pressed() -> void:
	if len(selected_items) != 0:
		# Events are added bellow the selected node
		# So we must reverse the adding order
		create_event1(DialogicSingleton.Event_Type.EndBranch)
		create_event1(DialogicSingleton.Event_Type.Condition)
	else:
		create_event1(DialogicSingleton.Event_Type.Condition)
		create_event1(DialogicSingleton.Event_Type.EndBranch)
	
	indent_events()
	
	editor_reference.need_save()

## *****************************************************************************
##					 	DRAG AND DROP
## *****************************************************************************

# Creates a ghost event for drag and drop
func create_drag_and_drop_event(scene: String):
	var index = get_index_under_cursor()
	var piece = create_event0(scene)
	timeline_node.move_child(piece, index)
	moving_piece = piece
	piece_was_dragged = true
	set_event_ignore_save(piece, true)
	select_item(piece)
	return piece

func drop_event():
	if moving_piece != null:
		set_event_ignore_save(moving_piece, false)
		moving_piece = null
		piece_was_dragged = false
		indent_events()

func cancel_drop_event():
	if moving_piece != null:
		moving_piece = null
		piece_was_dragged = false
		delete_selected_events()
		deselect_all_items()


## *****************************************************************************
##					 	CREATING THE TIMELINE
## *****************************************************************************

# Adding an event to the timeline_node
func create_event0(scene: String, data: Dictionary = {}):
	var piece = load("res://addons/dialogic/Editor/Events/" + scene + ".tscn").instance()
	
	piece.editor_reference = editor_reference
	
	if !data.empty():
		piece.event_data = data
	
	if len(selected_items) != 0:
		timeline_node.add_child_below_node(selected_items[0], piece)
	else:
		timeline_node.add_child(piece)

	piece.connect("option_action", self, '_on_event_options_action', [piece])
	piece.connect("gui_input", self, '_on_event_block_gui_input', [piece])
	
	events_warning.visible = false

	return piece

func create_event1(type:int, data: Dictionary = {}):
	return create_event0(DialogicSingleton.Event_Type.keys()[type], data)

func load_event(event):
	return create_event1(event["type"], event)

func load_timeline(name:String):
	#clear timeline
	deselect_all_items()
	
	for event in timeline_node.get_children():
		event.queue_free()
	
	#load it
	current_timeline = editor_reference.timelines[name]
	
	current_events = current_timeline["events"]
	
	for event in current_events:
		load_event(event)
	
	indent_events()

## *****************************************************************************
##					 	BLOCK GETTERS
## *****************************************************************************

func get_block_above(block):
	var block_index = block.get_index()
	var item = null
	if block_index > 0:
		item = timeline_node.get_child(block_index - 1)
	return item

func get_block_below(block):
	var block_index = block.get_index()
	var item = null
	if block_index < timeline_node.get_child_count() - 1:
		item = timeline_node.get_child(block_index + 1)
	return item

func get_block_height(block):
	if block != null:
		return block.rect_size.y
	else:
		return null

func get_index_under_cursor():
	var current_position = get_global_mouse_position()
	var top_pos = 0
	for i in range(timeline_node.get_child_count()):
		var c = timeline_node.get_child(i)
		if c.rect_global_position.y < current_position.y:
			top_pos = i
	return top_pos


# ordering blocks in timeline_node
func move_block(block, direction):
	var block_index = block.get_index()
	if direction == 'up':
		if block_index > 0:
			timeline_node.move_child(block, block_index - 1)
			return true
	if direction == 'down':
		timeline_node.move_child(block, block_index + 1)
		return true
	return false


## *****************************************************************************
##					 TIMELINE CREATION AND SAVING
## *****************************************************************************

# Saving
func generate_save_data():
	var info_to_save = {
		'metadata': {
			'dialogic-version': editor_reference.version_string,
			'name': timeline_name,
			'file': timeline_file
		},
		'events': []
	}
	for event in timeline_node.get_children():
		# Checking that the event is not waiting to be removed
		# or that it is not a drag and drop placeholder
		if not get_event_ignore_save(event) and event.is_queued_for_deletion() == false:
			info_to_save['events'].append(event.event_data)
	return info_to_save


func set_event_ignore_save(event: Node, ignore: bool):
	event.ignore_save = ignore
	

func get_event_ignore_save(event: Node) -> bool:
	return event.ignore_save


func save_timeline() -> void:
	current_events.clear()
	
	for event_node in timeline_node.get_children():
		# Checking that the event is not waiting to be removed
		# or that it is not a drag and drop placeholder
		if not get_event_ignore_save(event_node) and event_node.is_queued_for_deletion() == false:
			current_events.append(event_node.event_data)


## *****************************************************************************
##					 UTILITIES/HELPERS
## *****************************************************************************

# Event Indenting
func indent_events() -> void:
	var indent: int = 0
	var starter: bool = false
	var event_node_list: Array = timeline_node.get_children()
	var question_index: int = 0
	var question_indent = {}
	if event_node_list.size() < 2:
		return
	# Resetting all the indents
	for event_node in event_node_list:
		var indent_node
		
		event_node.set_indent(0)
		
	# Adding new indents
	for event_node in event_node_list:
		# since there are indicators now, not all elements
		# in this list have an event_data property
		if (not "event_data" in event_node):
			continue
		
		
		if event_node.event_data["type"] == DialogicSingleton.Event_Type.Choice:
			if question_index > 0:
				indent = question_indent[question_index] + 1
				starter = true
		elif (event_node.event_data["type"] == DialogicSingleton.Event_Type.Question or
			event_node.event_data["type"] == DialogicSingleton.Event_Type.Condition):
			indent += 1
			starter = true
			question_index += 1
			question_indent[question_index] = indent
		elif event_node.event_data["type"] == DialogicSingleton.Event_Type.EndBranch:
			if question_indent.has(question_index):
				indent = question_indent[question_index]
				indent -= 1
				question_index -= 1
				if indent < 0:
					indent = 0

		if indent > 0:
			# Keep old behavior for items without template
			if starter:
				event_node.set_indent(indent - 1)
			else:
				event_node.set_indent(indent)
		starter = false

# called from the toolbar
func fold_all_nodes():
	for event_node in timeline_node.get_children():
		event_node.set_expanded(false)

# called from the toolbar
func unfold_all_nodes():
	for event_node in timeline_node.get_children():
		event_node.set_expanded(true)
