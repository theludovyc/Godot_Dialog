tool
extends Control
class_name EditorView

onready var popup_removeConfirmation = $RemoveConfirmation

var editor_file_dialog # EditorFileDialog
var file_picker_data: Dictionary = {'method': '', 'node': self}
var version_string: String 

# this is set when the plugins main-view is instanced in GDialog.gd
var editor_interface = null

var res_values:Dictionary

var timelines:Dictionary

var characters:Dictionary

onready var timeline_editor = $MainPanel/TimelineEditor

onready var save_button = $ToolBar/SaveButton
var need_save = false

func _init():
	#Loading values
	res_values = GDialog_Resources.load_res_values()
	
	timelines = GDialog_Resources.load_timelines()
	
	characters = GDialog_Resources.load_characters()

func _ready():
	# Adding file dialog to get used by Events
	editor_file_dialog = EditorFileDialog.new()
	add_child(editor_file_dialog)

	# Setting references to this node
	timeline_editor.editor_reference = self
	$MainPanel/CharacterEditor.editor_reference = self
	$MainPanel/ValueEditor.editor_reference = self
	$MainPanel/GlossaryEntryEditor.editor_reference = self
	$MainPanel/ThemeEditor.editor_reference = self
	$MainPanel/DocumentationViewer.editor_reference = self

	$MainPanel/MasterTreeContainer/MasterTree.connect("editor_selected", self, 'on_master_tree_editor_selected')

	# Updating the folder structure
	#GDialog_Util.update_resource_folder_structure()
	
	# Sizes
	# This part of the code is a bit terrible. But there is no better way
	# of doing this in Godot at the moment. I'm sorry.
	var separation = get_constant("separation", "BoxContainer")
	$MainPanel.margin_left = separation
	$MainPanel.margin_right = separation * -1
	$MainPanel.margin_bottom = separation * -1
	$MainPanel.margin_top = 38
	var modifier = ''
	var _scale = get_constant("inspector_margin", "Editor")
	_scale = _scale * 0.125
	if _scale == 1:
		$MainPanel.margin_top = 30
	if _scale == 1.25:
		modifier = '-1.25'
		$MainPanel.margin_top = 37
	if _scale == 1.5:
		modifier = '-1.25'
		$MainPanel.margin_top = 46
	if _scale == 1.75:
		modifier = '-1.25'
		$MainPanel.margin_top = 53
	if _scale == 2:
		$MainPanel.margin_top = 59
		modifier = '-2'
	$ToolBar/NewTimelineButton.icon = load("res://addons/GDialog/Images/Toolbar/add-timeline" + modifier + ".svg")
	$ToolBar/NewCharactersButton.icon = load("res://addons/GDialog/Images/Toolbar/add-character" + modifier + ".svg")
	$ToolBar/NewValueButton.icon = load("res://addons/GDialog/Images/Toolbar/add-definition" + modifier + ".svg")
	$ToolBar/NewGlossaryEntryButton.icon = load("res://addons/GDialog/Images/Toolbar/add-glossary" + modifier + ".svg")
	$ToolBar/NewThemeButton.icon = load("res://addons/GDialog/Images/Toolbar/add-theme" + modifier + ".svg")
	
	var modulate_color = Color.white
	if not get_constant("dark_theme", "Editor"):
		modulate_color = get_color("property_color", "Editor")
	$ToolBar/NewTimelineButton.modulate = modulate_color
	$ToolBar/NewCharactersButton.modulate = modulate_color
	$ToolBar/NewValueButton.modulate = modulate_color
	$ToolBar/NewGlossaryEntryButton.modulate = modulate_color
	$ToolBar/NewThemeButton.modulate = modulate_color
	
	$ToolBar/FoldTools/ButtonFold.icon = get_icon("GuiTreeArrowRight", "EditorIcons")
	$ToolBar/FoldTools/ButtonUnfold.icon = get_icon("GuiTreeArrowDown", "EditorIcons")
	# Toolbar
	$ToolBar/NewTimelineButton.connect('pressed', $MainPanel/MasterTreeContainer/MasterTree, 'new_timeline')
	$ToolBar/NewCharactersButton.connect('pressed', $MainPanel/MasterTreeContainer/MasterTree, 'new_character')
	$ToolBar/NewThemeButton.connect('pressed', $MainPanel/MasterTreeContainer/MasterTree, 'new_theme')
	$ToolBar/NewValueButton.connect('pressed', $MainPanel/MasterTreeContainer/MasterTree, 'new_value_definition')
	$ToolBar/NewGlossaryEntryButton.connect('pressed', $MainPanel/MasterTreeContainer/MasterTree, 'new_glossary_entry')
	$ToolBar/Docs.icon = get_icon("Instance", "EditorIcons")
	$ToolBar/Docs.connect('pressed', OS, "shell_open", ["https://GDialog.coppolaemilio.com"])
	$ToolBar/FoldTools/ButtonFold.connect('pressed', $MainPanel/TimelineEditor, 'fold_all_nodes')
	$ToolBar/FoldTools/ButtonUnfold.connect('pressed', $MainPanel/TimelineEditor, 'unfold_all_nodes')
	
	#Connecting confirmation
	$RemoveFolderConfirmation.connect('confirmed', self, '_on_RemoveFolderConfirmation_confirmed')

	# Loading the version number
	var config = ConfigFile.new()
	var err = config.load("res://addons/GDialog/plugin.cfg")
	if err == OK:
		version_string = config.get_value("plugin", "version", "?")
		$ToolBar/Version.text = 'Dialogic v' + version_string
		
	$MainPanel/MasterTreeContainer/FilterMasterTreeEdit.right_icon = get_icon("Search", "EditorIcons")

	#Save
	save_button.connect("pressed", self, "on_save_button_pressed")

func on_master_tree_editor_selected(editor: String):
	$ToolBar/FoldTools.visible = editor == 'timeline'

func popup_remove_confirmation(what, what_name:String = ""):
	popup_removeConfirmation.dialog_text = "Are you sure you want to remove " + what_name + "? \n (Can't be restored)"
	
	if popup_removeConfirmation.is_connected('confirmed', self, '_on_RemoveConfirmation_confirmed'):
		popup_removeConfirmation.disconnect('confirmed', self, '_on_RemoveConfirmation_confirmed')
	
	popup_removeConfirmation.connect('confirmed', self, '_on_RemoveConfirmation_confirmed', [what, what_name])
	
	popup_removeConfirmation.popup_centered()


func _on_RemoveFolderConfirmation_confirmed():
	var item_path = $MainPanel/MasterTreeContainer/MasterTree.get_item_path($MainPanel/MasterTreeContainer/MasterTree.get_selected())
	GDialog_Util.remove_folder(item_path)
	$MainPanel/MasterTreeContainer/MasterTree.build_full_tree()


func _on_RemoveConfirmation_confirmed(what:String = "", what_name:String = ""):
	match what:
		"Value":
			res_values.erase(what_name)
			
			GDialog_Resources.save_res_values(res_values)
		
		"Timeline":
			timelines.erase(what_name)
			
			GDialog_Resources.delete_timeline(what_name)
		
		"Character":
			characters.erase(what_name)
			
			GDialog_Resources.delete_character(what_name)
		
		"GlossaryEntry":
			var target = $MainPanel/GlossaryEntryEditor.current_definition['id']
			GDialog_Resources.delete_default_definition(target)
			
		"Theme":
			var filename = $MainPanel/MasterTreeContainer/MasterTree.get_selected().get_metadata(0)['file']
			GDialog_Resources.delete_theme(filename)

#	GDialog_Util.update_resource_folder_structure()
	$MainPanel/MasterTreeContainer/MasterTree.remove_selected()
	
	$MainPanel/MasterTreeContainer/MasterTree.hide_all_editors()

func popup_select_file(who, method_name:String, filter:String = ""):
	editor_file_dialog.mode = EditorFileDialog.MODE_OPEN_FILE
	editor_file_dialog.clear_filters()
	
	if !filter.empty():
		editor_file_dialog.add_filter(filter)
	
	editor_file_dialog.popup_centered_ratio(0.75)
	
	for _signal in editor_file_dialog.get_signal_connection_list("file_selected"):
		editor_file_dialog.disconnect("file_selected", _signal["target"], _signal["method"])
	
	editor_file_dialog.connect("file_selected", who, method_name)

func popup_select_files(who, method_name:String, filter:String = ""):
	editor_file_dialog.mode = EditorFileDialog.MODE_OPEN_FILES
	editor_file_dialog.clear_filters()
	
	if !filter.empty():
		editor_file_dialog.add_filter(filter)
	
	editor_file_dialog.popup_centered_ratio(0.75)
	
	for _signal in editor_file_dialog.get_signal_connection_list("files_selected"):
		editor_file_dialog.disconnect("files_selected", _signal["target"], _signal["method"])
	
	editor_file_dialog.connect("files_selected", who, method_name)

# Godot dialog
func godot_dialog(filter, mode = EditorFileDialog.MODE_OPEN_FILE):
	editor_file_dialog.mode = mode
	editor_file_dialog.clear_filters()
	editor_file_dialog.popup_centered_ratio(0.75)
	editor_file_dialog.add_filter(filter)
	return editor_file_dialog


func godot_dialog_connect(who, method_name, signal_name = "file_selected"):
	# You can pass multiple signal_name using an array
	
	# Checking if previous connections exist, if they do, disconnect them.
	for test_signal in editor_file_dialog.get_signal_list():
		if editor_file_dialog.is_connected(
			test_signal.name,
			file_picker_data['node'],
			file_picker_data['method']
		):
				editor_file_dialog.disconnect(
					test_signal.name,
					file_picker_data['node'],
					file_picker_data['method']
				)
	
	# Connect new signals
	for new_signal_name in signal_name if typeof(signal_name) == TYPE_ARRAY else [signal_name]:
		editor_file_dialog.connect(new_signal_name, who, method_name, [who])
	
	file_picker_data['method'] = method_name
	file_picker_data['node'] = who

## *****************************************************************************
##						 RES
## *****************************************************************************
func create_new_res(dic:Dictionary, name:String, data) -> String:
	var values_id = 0
	
	while dic.has(name + str(values_id)):
		values_id += 1
	
	var key = name + str(values_id)
	
	dic[key] = data
	
	need_save()
	
	return key

func rename_res(dic:Dictionary, oldName:String, newName:String) -> bool:
	if dic.has(newName):
		return false
		
	dic[newName] = dic[oldName]
	
	dic.erase(oldName)
	
	need_save()
	
	return true

## *****************************************************************************
##						 VALUE
## *****************************************************************************
func create_new_value() -> String:
	return create_new_res(res_values, "NewValue", "0")

func change_value_name(oldName:String, newName:String) -> bool:
	return rename_res(res_values, oldName, newName)

func set_value(name:String, value:String):
	res_values[name] = value
	
	need_save()

## *****************************************************************************
##						 TIMELINE
## *****************************************************************************
func create_new_timeline() -> String:
	return create_new_res(timelines, "NewTimeline", {"events": []})
	
func change_timeline_name(oldName:String, newName:String) -> bool:
	if rename_res(timelines, oldName, newName):
		GDialog_Resources.rename_timeline(oldName, newName)
		return true
	return false

## *****************************************************************************
##						 CHARACTER
## *****************************************************************************

func create_new_character() -> String:
	return create_new_res(characters, "NewCharacter", {"portraits":{}})
	
func rename_character(oldName:String, newName:String) -> bool:
	if rename_res(characters, oldName, newName):
		GDialog_Resources.rename_character(oldName, newName)
		return true
	return false

## *****************************************************************************
##						 SAVE
## *****************************************************************************

func need_save():
	if !need_save:
		save_button.text = "Save(*)"
		
		need_save = true

func on_save_button_pressed():
	if !res_values.empty():
		GDialog_Resources.save_res_values(res_values)
	
	if !timelines.empty():
		for timeline in timelines:
			GDialog_Resources.save_timeline(timeline, timelines[timeline])
	
	if !characters.empty():
		for character in characters:
			GDialog_Resources.save_character(character, characters[character])
	
	save_button.text = "Save"
		
	need_save = false
