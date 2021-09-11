tool
extends EventPart

onready var lineEdit = $LineEdit

func _init():
	dataName = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	lineEdit.connect("text_changed", self, "_on_text_changed")

func init_data(data:Dictionary):
	if data.has(dataName):
		lineEdit.text = data[dataName]

func _on_text_changed(text:String):
	send_data({dataName:text})
