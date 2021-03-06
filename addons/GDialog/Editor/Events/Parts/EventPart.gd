tool
extends Control
class_name EventPart

signal data_changed
signal send_data(data)

# emit this to set the enabling of the body
signal request_set_body_enabled(enabled)

# emit these if you want the body to be closed/opened
signal request_open_body
signal request_close_body

# emit these if you want the event to be selected
signal request_selection

# emit this if you want a warning to be displayed/hidden
signal set_warning(text)
signal remove_warning()

export(String) var dataName = "data"

# has to be set by the parent before adding it to the tree
var editor_reference:EditorView
#var editorPopup

var event_data = {}

# when the node is ready
func _ready():
	pass

func on_ready():
	pass

func init_data(data:Dictionary):
	pass

# to be overwritten by the subclasses
func load_data(data:Dictionary):
	pass

# to be overwritten by body-parts that provide a preview
func get_preview_text():
	return ''


# has to be called everytime the data got changed
func data_changed():
	emit_signal("data_changed", event_data)

func send_data(data):
	emit_signal("send_data", data)
	
func reset():
	pass
