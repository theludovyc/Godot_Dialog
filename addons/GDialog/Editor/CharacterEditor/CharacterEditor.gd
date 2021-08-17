tool
extends ScrollContainer

var portrait_entry = preload("res://addons/GDialog/Editor/CharacterEditor/PortraitEntry.tscn")

onready var node_new_portrait_button = $HBoxContainer/Container/ScrollContainer/VBoxContainer/HBoxContainer/Button
onready var node_import_from_folder_button = $HBoxContainer/Container/ScrollContainer/VBoxContainer/HBoxContainer/ImportFromFolder
onready var node_display_name_checkbox = $HBoxContainer/Container/Name/CheckBox
onready var node_nickname_checkbox = $HBoxContainer/Container/Name/CheckBox2
onready var node_name = $HBoxContainer/Container/Name/LineEdit
onready var node_color = $HBoxContainer/Container/Color/ColorPickerButton
onready var node_file = $HBoxContainer/Container/FileName/LineEdit
onready var node_description = $HBoxContainer/Container/Description/TextEdit
onready var node_mirror_portraits_checkbox = $HBoxContainer/VBoxContainer/HBoxContainer/MirrorOption/MirrorPortraitsCheckBox
onready var node_displayName = $HBoxContainer/Container/DisplayName
onready var node_displayName_lineEdit = $HBoxContainer/Container/DisplayName/LineEdit
onready var node_displayNickname = $HBoxContainer/Container/DisplayNickname
onready var node_displayNickname_lineEdit = $HBoxContainer/Container/DisplayNickname/LineEdit
onready var node_portrait_preview = $HBoxContainer/VBoxContainer/Control/TextureRect
onready var node_image_label = $HBoxContainer/VBoxContainer/Control/Label
onready var node_scale = $HBoxContainer/VBoxContainer/HBoxContainer/Scale
onready var node_offset_x = $HBoxContainer/VBoxContainer/HBoxContainer/OffsetX
onready var node_offset_y = $HBoxContainer/VBoxContainer/HBoxContainer/OffsetY
onready var node_portraitList = $HBoxContainer/Container/ScrollContainer/VBoxContainer/PortraitList

var editor_reference
onready var master_tree = get_node('../MasterTreeContainer/MasterTree')

var current_character:Dictionary

func _ready():
	node_new_portrait_button.connect('pressed', self, '_on_New_Portrait_Button_pressed')
	node_import_from_folder_button.connect('pressed', self, '_on_Import_Portrait_Folder_Button_pressed')
	node_display_name_checkbox.connect('toggled', self, '_on_display_name_toggled')
	node_nickname_checkbox.connect('toggled', self, '_on_nickname_toggled')
	node_color.connect('color_changed', self, '_on_color_changed')
	node_description.connect("text_changed", self, "on_description_changed")
	
	var style = get('custom_styles/bg')
	style.set('bg_color', get_color("base_color", "Editor"))
	
	node_new_portrait_button.icon = get_icon("Add", "EditorIcons")
	node_import_from_folder_button.icon = get_icon("Folder", "EditorIcons")

func _on_display_name_toggled(button_pressed):
	node_displayName.visible = button_pressed

func _on_nickname_toggled(button_pressed):
	node_displayNickname.visible = button_pressed

func is_selected(file: String):
	return node_file.text == file

func _on_color_changed(color):
	var item = master_tree.get_selected()
	item.set_icon_modulate(0, color)
	
	current_character["color"] = "#" + color.to_html()
	
	editor_reference.need_save()

func on_description_changed():
	current_character["description"] = node_description.text
	
	editor_reference.need_save()

func clear_character_editor():
	node_file.text = ""
	node_name.text = ""
	node_description.text = ""
	node_color.color = Color('#ffffff')
	node_mirror_portraits_checkbox.pressed = false
	node_display_name_checkbox.pressed = false
	node_nickname_checkbox.pressed = false
	node_displayName_lineEdit.text = ""
	node_displayNickname_lineEdit.text = ""
	node_scale.value = 100
	node_offset_x.value = 0
	node_offset_y.value = 0

	# Clearing portraits
	for p in node_portraitList.get_children():
		p.queue_free()
	node_portrait_preview.texture = null

# Saving and Loading
func generate_character_data_to_save():
	var portraits = []
	for p in node_portraitList.get_children():
		var entry = {}
		entry['name'] = p.get_node("NameEdit").text
		entry['path'] = p.get_node("PathEdit").text
		portraits.append(entry)
	var info_to_save = {
		'id': node_file.text,
		'description': node_description.text,
		'color': '#' + node_color.color.to_html(),
		'mirror_portraits': node_mirror_portraits_checkbox.pressed,
		'portraits': portraits,
		'display_name_bool': node_display_name_checkbox.pressed,
		'display_name': node_displayName_lineEdit.text,
		'nickname_bool': node_nickname_checkbox.pressed,
		'nickname': node_displayNickname_lineEdit.text,
		'scale': node_scale.value,
		'offset_x': node_offset_x.value,
		'offset_y': node_offset_y.value,
	}
	# Adding name later for cases when no name is provided
	if node_name.text != "":
		info_to_save['name'] = node_name.text
	
	return info_to_save

func save_character():
	var info_to_save = generate_character_data_to_save()
	if info_to_save['id']:
		GDialog_Resources.set_character(info_to_save)
		current_character = info_to_save

func load_character(name:String):
	clear_character_editor()
	
	current_character = editor_reference.characters[name]

	node_name.text = name
	node_description.text = current_character.get('description', "")
	node_color.color = Color(current_character.get('color','#ffffffff'))
	node_display_name_checkbox.pressed = current_character.get('display_name_bool', false)
	node_displayName_lineEdit.text = current_character.get('display_name', "")
	node_scale.value = float(current_character.get('scale', 100))
	node_nickname_checkbox.pressed = current_character.get('nickname_bool', false)
	node_displayNickname_lineEdit.text = current_character.get('nickname', "")
	node_offset_x.value = current_character.get('offset_x', 0)
	node_offset_y.value = current_character.get('offset_y', 0)
	node_mirror_portraits_checkbox.pressed = current_character.get('mirror_portraits', false)
	node_portrait_preview.flip_h = current_character.get('mirror_portraits', false)

	# Portraits
	if current_character.has('portraits'):
		for p in current_character['portraits']:
			create_portrait_entry(p['name'], p['path'])

# Portraits
func on_files_selected(paths:PoolStringArray):
	if !paths.empty():
		for path in paths:
			var name = path.get_file().get_basename()
		
			create_portrait_entry(name, path)
		
			current_character["portraits"].append({"name":name, "path":path})
	
		editor_reference.need_save()

func _on_New_Portrait_Button_pressed():
	editor_reference.popup_select_files(self, "on_files_selected", "*.png, *.svg")

func create_portrait_entry(p_name = "", path = "", grab_focus = false):
	var p = portrait_entry.instance()
	
	p.editor_reference = editor_reference
	p.image_node = node_portrait_preview
	p.image_label = node_image_label
	
	if !p_name.empty():
		p.get_node("NameEdit").text = p_name
		
	if !path.empty():
		p.get_node("PathEdit").text = path
		
	if grab_focus:
		p.get_node("NameEdit").grab_focus()
		
	node_portraitList.add_child(p)
	
	p.node_buttonDelete.connect("pressed", self, "on_portrait_buttonDelete", [p])
	return p

func on_portrait_buttonDelete(p):
	current_character["portraits"].remove(p.get_index())
	
	p.queue_free()
	
	editor_reference.need_save()

func _on_MirrorPortraitsCheckBox_toggled(button_pressed):
	node_portrait_preview.flip_h = button_pressed
