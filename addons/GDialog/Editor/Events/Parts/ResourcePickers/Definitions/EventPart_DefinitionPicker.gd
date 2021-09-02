tool
extends EventPart

var icon = preload("res://addons/GDialog/Images/Resources/definition.svg")

# has an event_data variable that stores the current data!!!
export (String) var default_text = "Select Value"

## node references
onready var picker_menu = $MenuButton

var current_popup_menu

# used to connect the signals
func _ready():
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")

func init_data(data:Dictionary):
	if data.has("definition"):
		var value_name = data["definition"]
		
		if editor_reference.res_values.has(value_name):
			picker_menu.text = value_name
	
# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

# when an index is selected on one of the menus.
func _on_PickerMenu_selected(index):
	var text = current_popup_menu.get_item_text(index)
	
	picker_menu.text = text
	
	# informs the parent about the changes!
	send_data({"definition":text})

func _on_PickerMenu_about_to_show():
	current_popup_menu = picker_menu.get_popup()
	
	# Building the picker menu()
	current_popup_menu.clear()
	
	## building the root level
	for value in editor_reference.res_values:
		current_popup_menu.add_icon_item(icon, value)

	if not current_popup_menu.is_connected("index_pressed", self, "_on_PickerMenu_selected"):
		current_popup_menu.connect("index_pressed", self, "_on_PickerMenu_selected")

func reset():
	if picker_menu.text != default_text:
		picker_menu.text = default_text
	
		send_data({"definition":""})
