tool
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

## node references
onready var picker_menu = $MenuButton

onready var picker_popup = picker_menu.get_popup()

# used to connect the signals
func on_ready():
	picker_popup.add_item("=")
	picker_popup.add_item("+")
	picker_popup.add_item("-")
	picker_popup.add_item("*")
	picker_popup.add_item("/")
	
	picker_popup.connect("index_pressed", self, '_on_PickerMenu_selected')

# called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Now update the ui nodes to display the data. 
	picker_menu.text = data.get("operation", "=")
	
# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func _on_PickerMenu_selected(index):
	var text = picker_popup.get_item_text(index)
	
	event_data['operation'] = text
	
	picker_menu.text = text
	
	# informs the parent about the changes!
	data_changed()
