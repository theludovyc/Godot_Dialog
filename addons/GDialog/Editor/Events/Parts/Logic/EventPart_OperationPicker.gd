tool
extends EventPart

## node references
onready var picker_menu = $MenuButton

onready var picker_popup = picker_menu.get_popup()

const operations = {
	"=":"=",
	"+=":"= itself +",
	"-=":"= itself -",
	"*=":"= itself *",
	"/=":"= itself /",
}

# used to connect the signals
func on_ready():
	for value in operations.values():
		picker_popup.add_item(value)
	
	picker_popup.connect("index_pressed", self, '_on_PickerMenu_selected')

# called by the event block
func init_data(data:Dictionary):
	if !data.has("operation"):
		data["operation"] = "="
		
		send_data({"operation":"="})
	
	picker_menu.text = operations[data["operation"]]
	
# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func _on_PickerMenu_selected(index):
	var text = picker_popup.get_item_text(index)
	
	picker_menu.text = text
	
	# informs the parent about the changes!
	send_data({"operation":operations.keys()[index]})
