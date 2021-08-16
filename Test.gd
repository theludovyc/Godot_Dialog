extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var node = GDialog.start("NewTimeline1")
	add_child(node)
	
	GDialog.set_value("NewValue0", 2)
	
	print(GDialog.get_value("NewValue0"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
