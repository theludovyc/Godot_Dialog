tool
extends EventPart

## node references
onready var number_box = $NumberBox

# used to connect the signals
func _ready():
	number_box.connect("value_changed", self, "_on_NumberBox_value_changed")

# called by the event block
func init_data(data:Dictionary):
	if data.has(dataName):
		number_box.value = data[dataName]

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func _on_NumberBox_value_changed(value):
	send_data({dataName:value})
