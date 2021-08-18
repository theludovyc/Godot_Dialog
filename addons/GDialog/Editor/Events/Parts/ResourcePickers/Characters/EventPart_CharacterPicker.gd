tool
extends EventPart

var character_icon = preload("res://addons/GDialog/Images/Resources/character.svg")

# has an event_data variable that stores the current data!!!

## node references
onready var picker_menu = $HBox/MenuButton
onready var icon = $HBox/Icon

func _ready():
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")

# called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Now update the ui nodes to display the data. 
	update_to_character()

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

# helper to not have the same code everywhere
func update_to_character():
	if event_data.has("character") and !event_data["character"].empty():
		var character = event_data['character']
		
		if character == '[All]':
			picker_menu.text = "All characters"
			icon.modulate = Color.white
		else:
			picker_menu.text = character
			icon.modulate = editor_reference.characters[character]["color"]
	else:
		picker_menu.text = 'No Character'
		icon.modulate = Color.white

# when an index is selected on one of the menus.
func _on_PickerMenu_selected(index, menu):
	var name = menu.get_item_text(index)
	
	event_data["character"] = name
	
	update_to_character()
	
	# informs the parent about the changes!
	data_changed()

func _on_PickerMenu_about_to_show():
	var popup_menu = picker_menu.get_popup()
	
	popup_menu.clear()
	
	for character in editor_reference.characters:
		popup_menu.add_icon_item(character_icon, character["name"])
	
	if not popup_menu.is_connected("index_pressed", self, "_on_PickerMenu_selected"):
		popup_menu.connect("index_pressed", self, '_on_PickerMenu_selected', [popup_menu])
