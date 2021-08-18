tool
extends EventPart

## node references
onready var picker_menu = $HBox/MenuButton

var popup_menu

# used to connect the signals
func _ready():
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")
	
	popup_menu = picker_menu.get_popup()
	
	popup_menu.connect("index_pressed", self, '_on_PickerMenu_selected')
	

# called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Now update the ui nodes to display the data. 
	if event_data.has("portrait"):
		picker_menu.text = event_data["portrait"]

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func _on_PickerMenu_selected(index):
	var name = popup_menu.get_item_text(index)
	
	event_data["portrait"] = name
	
	picker_menu.text = name
	
	# informs the parent about the changes!
	data_changed()

func _on_PickerMenu_about_to_show():
	popup_menu.clear()
	
	if event_data.has("character"):
		var character = editor_reference.characters[event_data["character"]]
		
		if character.has("portraits"):
			for p in character["portraits"]:
				popup_menu.add_item(p["name"])
