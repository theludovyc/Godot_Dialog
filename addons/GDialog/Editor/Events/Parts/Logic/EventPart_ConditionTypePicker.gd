tool
extends EventPart

# has an event_data variable that stores the current data!!!
const options = {
	"=":"=",
	"!=":"not =",
	">":">",
	">=":"> or =",
	"<":"<",
	"<=":"< or ="
}

## node references
onready var picker_menu = $MenuButton

onready var picker_popup = picker_menu.get_popup()

# used to connect the signals
func _ready():
	for value in options.values():
		picker_popup.add_item(value)
	
	picker_popup.connect("index_pressed", self, '_on_PickerMenu_selected')

# called by the event block
func init_data(data:Dictionary):
	if !data.has("condition"):
		data["condition"] = "="
		
		send_data({"condition":"="})
	
	picker_menu.text = options[data["condition"]]

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func _on_PickerMenu_selected(index):
	var text = picker_popup.get_item_text(index)
	
	picker_menu.text = text
	
	# informs the parent about the changes!
	send_data({"condition":options.keys()[index]})

func reset():
	if picker_menu.text != "=":
		picker_menu.text = options["="]
	
		send_data({"condition":"="})
