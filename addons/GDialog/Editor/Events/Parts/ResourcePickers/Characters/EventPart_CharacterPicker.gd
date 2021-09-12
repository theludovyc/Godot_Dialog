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
func init_data(data:Dictionary):
	if data.has("character"):
		update_character(data["character"])

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

# helper to not have the same code everywhere
func update_character(char_name:String):
	if char_name == '[All]':
		picker_menu.text = "All characters"
		icon.modulate = Color.white
	else:
		picker_menu.text = char_name
		icon.modulate = editor_reference.characters[char_name]["color"]

# when an index is selected on one of the menus.
func _on_PickerMenu_selected(index, menu):
	var name = menu.get_item_text(index)
	
	update_character(name)
	
	# informs the parent about the changes!
	send_data({"character":name})

func _on_PickerMenu_about_to_show():
	var popup_menu = picker_menu.get_popup()
	
	popup_menu.clear()
	
	for character in editor_reference.characters:
		popup_menu.add_icon_item(character_icon, character)
	
	if not popup_menu.is_connected("index_pressed", self, "_on_PickerMenu_selected"):
		popup_menu.connect("index_pressed", self, '_on_PickerMenu_selected', [popup_menu])
