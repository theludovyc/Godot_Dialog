tool
extends EventPart

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Array, NodePath) var paths

onready var checkPicker = $CheckBox

var nodes:Array

func _init():
	dataName = "check"
	
func _ready():
	for path in paths:
		nodes.append(get_node(path))

func resetNodes():
	for node in nodes:
		node.visible = !node.visible
		
		if node is EventPart and !node.visible:
			node.reset()

func init_data(data:Dictionary):
	checkPicker.pressed = data.get(dataName, false)
	
	if checkPicker.pressed:
		resetNodes()

func _on_CheckPicker_toggled(button_pressed):
	resetNodes()
	
	send_data({dataName:button_pressed})
