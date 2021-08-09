tool
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

# has an event_data variable that stores the current data!!!

## node references
onready var picker_menu = $MenuButton

# used to connect the signals
func _ready():
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")


# called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Now update the ui nodes to display the data. 
	if event_data.has("change_timeline"):
		var timeline_name = event_data["change_timeline"]
		
		if editor_reference.timelines.has(timeline_name):
			picker_menu.text = timeline_name
			return
			
	picker_menu.text = "Select Timeline"


# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''


# when an index is selected on one of the menus.
func _on_PickerMenu_selected(index, menu):
	var text = menu.get_item_text(index)
	
	picker_menu.text = text
	
	event_data['change_timeline'] = text
	
	# informs the parent about the changes!
	data_changed()


func _on_PickerMenu_about_to_show():
	var menu_popup = picker_menu.get_popup()
	
	menu_popup.clear()
	
	var index = 0
	
	var timelines = editor_reference.timelines
	
	for timeline in timelines:
		menu_popup.add_item(timeline)
		menu_popup.set_item_icon(index, editor_reference.get_node("MainPanel/MasterTreeContainer/MasterTree").timeline_icon)
		index += 1
	
	if not menu_popup.is_connected("index_pressed", self, "_on_PickerMenu_selected"):
		menu_popup.connect("index_pressed", self, '_on_PickerMenu_selected', [menu_popup])
