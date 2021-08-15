tool
extends EventPart

# has an event_data variable that stores the current data!!!
var default_icon_color = Color("#65989898")

## node references
onready var positions_container = $HBox/PositionsContainer

# used to connect the signals
func _ready():
	for p in positions_container.get_children():
		p.connect('pressed', self, "position_button_pressed", [p.name])

# called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Now update the ui nodes to display the data.
	if !data.has("position"):
		data["position"] = [true, false, false, false, false]
	
	check_active_position()

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func get_character_color():
	for ch in GDialog_Util.get_character_list():
		if ch['file'] == event_data['character']:
			return ch['color']
	return Color.white

func position_button_pressed(name):
	clear_all_positions()
	var selected_index = name.split('-')[1]
	var button = positions_container.get_node('position-' + selected_index)
	button.set('self_modulate', get_character_color())
	button.pressed = true
	
	event_data['position'][int(selected_index)] = true
	
	data_changed()

func clear_all_positions():
	for i in range(5):
		event_data['position'][i] = false
	for p in positions_container.get_children():
		p.set('self_modulate', default_icon_color)
		p.pressed = false


func check_active_position(active_color = Color("#ffffff")):
	var index = 0
	for p in positions_container.get_children():
		if event_data.has("position") and event_data['position'][index]:
			p.pressed = true
			p.set('self_modulate', get_character_color())
		index += 1

