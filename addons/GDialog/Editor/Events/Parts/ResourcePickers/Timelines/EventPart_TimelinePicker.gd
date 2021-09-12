tool
extends EventPart

# has an event_data variable that stores the current data!!!

## node references
onready var picker_menu = $MenuButton

var popup_menu

# used to connect the signals
func _ready():
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")
	
	popup_menu = picker_menu.get_popup()
	
	popup_menu.connect("index_pressed", self, '_on_PickerMenu_selected')

# called by the event block
func init_data(data:Dictionary):
	if data.has("timeline"):
		var timeline_name = data["timeline"]
		
		if editor_reference.timelines.has(timeline_name):
			picker_menu.text = timeline_name
			return
			
	picker_menu.text = "Select Timeline"


# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

# when an index is selected on one of the menus.
func _on_PickerMenu_selected(index):
	var text = popup_menu.get_item_text(index)
	
	picker_menu.text = text
	
	send_data({"timeline":text})

func _on_PickerMenu_about_to_show():
	popup_menu.clear()
	
	for timeline in editor_reference.timelines:
		popup_menu.add_item(timeline)
