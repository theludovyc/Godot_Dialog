tool
extends EventPart

## node references
onready var picker_menu = $HBox/MenuButton

var popup_menu

# used to connect the signals
func _ready():
	popup_menu = picker_menu.get_popup()
	
	popup_menu.connect("index_pressed", self, '_on_PickerMenu_selected')

# called by the event block
func init_data(data:Dictionary):
	if data.has("portrait"):
		picker_menu.text = event_data["portrait"]

# called by the event block
func load_data(data:Dictionary):
	if data.has("character"):
		var char_name = data["character"]
		
		popup_menu.clear()
		
		var character = editor_reference.characters[char_name]
		
		if character.has("portraits"):
			for p in character["portraits"]:
				popup_menu.add_item(p)

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func _on_PickerMenu_selected(index):
	var name = popup_menu.get_item_text(index)
	
	picker_menu.text = name
	
	# informs the parent about the changes!
	send_data({"portrait":name})
