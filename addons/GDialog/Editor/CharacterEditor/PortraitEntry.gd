tool
extends HBoxContainer

onready var node_nameEdit = $NameEdit.text
onready var node_pathEdit = $PathEdit.text
onready var node_buttonDelete = $ButtonDelete

var editor_reference
var image_node
var image_label

func _ready():
	node_buttonDelete.icon = get_icon("Remove", "EditorIcons")

func _on_ButtonSelect_pressed():
	editor_reference.godot_dialog("*.png, *.svg, *.tscn")
	editor_reference.godot_dialog_connect(self, "_on_file_selected")

func _on_file_selected(path, target):
	update_preview(path)
	node_pathEdit = path
	if node_nameEdit == '':
		node_nameEdit = GDialog_Resources.get_filename_from_path(path)

func _on_focus_entered():
	if node_pathEdit == '':
		image_label.text = 'Preview - No image on this portrait entry.'
		image_node.texture = null
	else:
		update_preview(node_pathEdit)

func update_preview(path):
	image_label.text = 'Preview'
	var l_path = path.to_lower()
	if '.png' in l_path or '.svg' in l_path:
		image_node.texture = load(path)
		image_label.text = 'Preview - ' + str(image_node.texture.get_width()) + 'x' + str(image_node.texture.get_height())
	elif '.tscn' in l_path:
		image_node.texture = null
		image_label.text = '[!] Can\'t show previews of custom scenes.'
	else:
		image_node.texture = null
