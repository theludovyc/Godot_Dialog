tool
extends ScrollContainer

var portrait_entry = preload("res://addons/GDialog/Editor/CharacterEditor/PortraitEntry.tscn")

onready var node_new_portrait_button = $HBoxContainer/Container/ScrollContainer/VBoxContainer/HBoxContainer/Button
onready var node_color = $HBoxContainer/Container/Color/ColorPickerButton
onready var node_description = $HBoxContainer/Container/Description/TextEdit
onready var node_mirror_portraits_checkbox = $HBoxContainer/VBoxContainer/HBoxContainer/MirrorOption/MirrorPortraitsCheckBox
onready var node_portrait_preview = $HBoxContainer/VBoxContainer/Control/TextureRect
onready var node_image_label = $HBoxContainer/VBoxContainer/Control/Label
onready var node_scale = $HBoxContainer/VBoxContainer/HBoxContainer/Scale
onready var node_offset_x = $HBoxContainer/VBoxContainer/HBoxContainer/OffsetX
onready var node_offset_y = $HBoxContainer/VBoxContainer/HBoxContainer/OffsetY
onready var node_portraitList = $HBoxContainer/Container/ScrollContainer/VBoxContainer/PortraitList

var editor_reference:EditorView
onready var master_tree = get_node('../MasterTreeContainer/MasterTree')

var current_character:Dictionary

func _ready():
	node_new_portrait_button.connect('pressed', self, '_on_New_Portrait_Button_pressed')
	node_color.connect('color_changed', self, '_on_color_changed')
	node_description.connect("text_changed", self, "on_description_changed")
	node_scale.connect("value_changed", self, "on_scale_changed")
	node_offset_x.connect("value_changed", self, "on_offset_x_changed")
	node_offset_y.connect("value_changed", self, "on_offset_y_changed")
	node_mirror_portraits_checkbox.connect("toggled", self, "_on_MirrorPortraitsCheckBox_toggled")
	
	var style = get('custom_styles/bg')
	style.set('bg_color', get_color("base_color", "Editor"))
	
	node_new_portrait_button.icon = get_icon("Add", "EditorIcons")

func _on_color_changed(color):
	var item = master_tree.get_selected()
	item.set_icon_modulate(0, color)
	
	current_character["color"] = "#" + color.to_html()
	
	editor_reference.need_save()

func on_description_changed():
	current_character["description"] = node_description.text
	
	editor_reference.need_save()

func on_scale_changed(value:float):
	current_character["scale"] = value / 100
	
	editor_reference.need_save()
	
func on_offset_x_changed(value:float):
	current_character["offset_x"] = value
	
	editor_reference.need_save()

func on_offset_y_changed(value:float):
	current_character["offset_y"] = value
	
	editor_reference.need_save()

func clear_character_editor():
	# Clearing portraits
	for p in node_portraitList.get_children():
		p.queue_free()
		
	node_portrait_preview.texture = null

func load_character(name:String):
	clear_character_editor()
	
	current_character = editor_reference.characters[name]

	node_description.text = current_character.get('description', "")
	node_color.color = Color(current_character.get('color','#ffffffff'))
	node_scale.get_line_edit().text = str(current_character.get("scale", 1) * 100)
	node_offset_x.get_line_edit().text = str(current_character.get('offset_x', 0))
	node_offset_y.get_line_edit().text = str(current_character.get('offset_y', 0))
	
	node_mirror_portraits_checkbox.set_block_signals(true)
	node_mirror_portraits_checkbox.pressed = current_character.get('mirror_portraits', false)
	node_mirror_portraits_checkbox.set_block_signals(false)
	
	node_portrait_preview.flip_h = current_character.get('mirror_portraits', false)

	# Portraits
	if current_character.has("portraits"):
		var portraits = current_character["portraits"]
		
		for portrait_name in portraits:
			create_portrait_entry(portrait_name, portraits[portrait_name])

# Portraits
func on_files_selected(paths:PoolStringArray):
	if !paths.empty():
		for path in paths:
			var name = path.get_file().get_basename()
		
			create_portrait_entry(name, path)
		
			current_character["portraits"][name] = path
	
		editor_reference.need_save()

func _on_New_Portrait_Button_pressed():
	editor_reference.popup_select_files(self, "on_files_selected", "*.png, *.svg")

func create_portrait_entry(p_name, path, grab_focus = false):
	var p = portrait_entry.instance()
	
	p.name = p_name
	p.editor_reference = editor_reference
	p.image_node = node_portrait_preview
	p.image_label = node_image_label
		
	node_portraitList.add_child(p)
	
	p.node_nameEdit.text = p_name
		
	p.node_pathEdit.text = path
		
	if grab_focus:
		p.node_nameEdit.grab_focus()
	
	p.node_buttonDelete.connect("pressed", self, "on_portrait_buttonDelete", [p])
	p.connect("path_changed", self, "on_portrait_path_changed", [p])
	p.node_nameEdit.connect("text_changed", self, "on_portrait_name_changed", [p])
	
	return p

func on_portrait_buttonDelete(p):
	current_character["portraits"].erase(p.name)
	
	p.queue_free()
	
	editor_reference.need_save()
	
func on_portrait_path_changed(path, p):
	current_character["portraits"][p.name] = path
	
	editor_reference.need_save()
	
func on_portrait_name_changed(text, p):
	if GDialog_Util.dic_rename(current_character["portraits"], p.name, text):
		p.name = text
		
		editor_reference.need_save()
	else:
		p.node_nameEdit.text = p.name
	

func _on_MirrorPortraitsCheckBox_toggled(button_pressed):
	node_portrait_preview.flip_h = button_pressed
	
	current_character["mirror_portraits"] = button_pressed
	
	editor_reference.need_save()
