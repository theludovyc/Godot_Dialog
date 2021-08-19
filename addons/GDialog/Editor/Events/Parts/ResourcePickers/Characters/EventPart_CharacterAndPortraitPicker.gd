tool
extends EventPart

# has an event_data variable that stores the current data!!!
export (bool) var allow_portrait_dont_change := true
export (bool) var allow_portrait_defintion := true

## node references
onready var character_picker = $HBox/CharacterPicker
onready var portrait_picker = $HBox/PortraitPicker
onready var definition_picker = $HBox/DefinitionPicker

# used to connect the signals
func on_ready():
	character_picker.editor_reference = editor_reference
	character_picker.connect("data_changed", self, "_on_CharacterPicker_data_changed")
	
	portrait_picker.editor_reference = editor_reference
	portrait_picker.connect("data_changed", self, "_on_PortraitPicker_data_changed")

#	portrait_picker.allow_dont_change = allow_portrait_dont_change
#	portrait_picker.allow_definition = allow_portrait_defintion
	
	definition_picker.connect("data_changed", self, "_on_DefinitionPicker_data_changed")
	
# called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Now update the ui nodes to display the data.
	character_picker.load_data(data)
	
	portrait_picker.load_data(data)
	
#	var has_port_defn = false
#
#	if data.has("portrait"):
#		has_port_defn = data['portrait'] == '[Definition]'
#
#	if has_port_defn and data.has('port_defn'):
#		definition_picker.load_data({ 'definition': data['port_defn'] })
#	definition_picker.visible = has_port_defn

# has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

func _on_CharacterPicker_data_changed(data):
	event_data = data
	
	# update the portrait picker data
	portrait_picker.load_data(data)
	
	# informs the parent about the changes!
	data_changed()

func _on_PortraitPicker_data_changed(data):
	event_data = data
	
	# informs the parent about the changes!
	data_changed()

func _on_DefinitionPicker_data_changed(data):
	event_data['port_defn'] = data['definition']

	# informs the parent about the changes!
	data_changed()
