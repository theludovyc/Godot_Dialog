tool
extends EventPart

# has an event_data variable that stores the current data!!!

## node references
onready var file_button = $FileButton
onready var clear_button = $ClearButton

export(String) var filetype

# used to connect the signals
func _ready():
	pass

# called by the event block
func init_data(data:Dictionary):
	var file_name = data.get("file", "")
	
	if !file_name.empty():
		file_button.text = file_name.get_file()
		
		clear_button.disabled = false
	

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func _on_FileButton_pressed():
	editor_reference.godot_dialog(filetype)
	editor_reference.godot_dialog_connect(self, "_on_file_selected")

func _on_file_selected(path:String, target):
	var file_name = path.get_file()
	
	file_button.text = file_name
	
	clear_button.disabled = false
	
	send_data({"file":path})

func _on_ClearButton_pressed():
	file_button.text = "Select File"
	
	clear_button.disabled = true
	
	send_data({"file":""})
