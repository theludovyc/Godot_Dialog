tool
extends EventPart

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Array, NodePath) var paths

onready var checkPicker = $CheckPicker

var nodes:Array

func _init():
	dataName = "check"
	
func _ready():
	for path in paths:
		nodes.append(get_node(path))

func resetNodes(var b:bool):
	for node in nodes:
		node.visible = b
		
		if !b:
			node.reset()

func init_data(data:Dictionary):
	checkPicker.pressed = data.get(dataName, false)
	
	resetNodes(checkPicker.pressed)

func _on_CheckPicker_toggled(button_pressed):
	resetNodes(button_pressed)
	
	send_data({dataName:button_pressed})
