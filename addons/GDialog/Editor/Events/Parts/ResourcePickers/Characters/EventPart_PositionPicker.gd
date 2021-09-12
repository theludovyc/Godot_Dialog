tool
extends EventPart

## node references
onready var positions_container = $HBox/PositionsContainer

# has an event_data variable that stores the current data!!!
const default_color = Color("#65989898")

# used to connect the signals
func _ready():
	for button in positions_container.get_children():
		button.connect('pressed', self, "position_button_pressed", [button])

# called by the event block
func init_data(data:Dictionary):
	var button = positions_container.get_child(data.get("position", 0))
	
	button.pressed = true
	button.set("self_modulate", Color.white)

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func position_button_pressed(button:Node):
	for _button in positions_container.get_children():
		_button.set('self_modulate', default_color)
		_button.pressed = false
	
	button.set('self_modulate', Color.white)
	button.pressed = true
	
	send_data({"position":button.get_index()})
