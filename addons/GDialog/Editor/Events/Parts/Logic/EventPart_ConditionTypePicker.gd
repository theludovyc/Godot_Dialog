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
		
	print("TypePicker", "hello")
	
	picker_popup.connect("index_pressed", self, '_on_PickerMenu_selected')

# called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Now update the ui nodes to display the data.
	if !data.has("condition"):
		event_data["condition"] = "="
		
		data_changed()
	
	picker_menu.text = options[event_data["condition"]]

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func _on_PickerMenu_selected(index):
	var text = picker_popup.get_item_text(index)
	
	event_data["condition"] = options.keys()[index]
	
	picker_menu.text = text
	
	# informs the parent about the changes!
	data_changed()

func reset():
	if event_data["condition"] != "=":
		event_data["condition"] = "="
	
		picker_menu.text = options["="]
	
		data_changed()
