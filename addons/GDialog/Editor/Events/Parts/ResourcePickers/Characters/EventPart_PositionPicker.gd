tool
extends EventPart

## node references
onready var positions_container = $HBox/PositionsContainer

# has an event_data variable that stores the current data!!!
const default_color = Color("#65989898")

var index:int

var current_color:Color

# used to connect the signals
func _ready():
	for button in positions_container.get_children():
		button.connect('pressed', self, "position_button_pressed", [button])

# called by the event block
func load_data(data:Dictionary):
	if data.has("character"):
		var char_name = data["character"]
	
		current_color = editor_reference.characters[char_name]["color"]
	
		positions_container.get_child(index).set('self_modulate', current_color)

# called by the event block
func init_data(data:Dictionary):
	index = data.get("position", 0)
	
	positions_container.get_child(index).pressed = true
	
	load_data(data)

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func position_button_pressed(button:Node):
	for _button in positions_container.get_children():
		_button.set('self_modulate', default_color)
		_button.pressed = false
	
	button.set('self_modulate', current_color)
	button.pressed = true
	
	index = button.get_index()
	
	send_data({"position":index})
