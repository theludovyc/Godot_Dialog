extends EventPart

onready var node_text = $LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	node_text.connect("text_changed", self, "_on_text_changed")

func init_data(data:Dictionary):
	if data.has("text"):
		node_text.text = data["text"]

func _on_text_changed(text:String):
	send_data({"text":text})
