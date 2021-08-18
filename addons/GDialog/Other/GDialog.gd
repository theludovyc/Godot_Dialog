extends Node

## This script is added as an AutoLoad when the plugin is activated
## It is used during game execution to access the dialogic resources

## Mainly it's used by the dialog_node.gd and the DialogicClass
## In your game you should consider using the methods of the DialogicClass!

var current_definitions := {}
var default_definitions := {}

var values:Dictionary

var timelines:Dictionary

var characters:Dictionary

var current_state := {}
var autosave := true

var current_timeline := ''

enum Event_Type{
	#Main Events
	Text=0,
	SetMood,
	CharacterJoin,
	CharacterLeave,
	
	#Logic Events
	Question,
	Choice,
	Condition,
	EndBranch,
	SetValue,
	
	#Timeline Events
	ChangeTimeline,
	ChangeBackground,
	CloseDialog,
	Wait,
	SetTheme,
	SetGlossary,
	
	#Audio Events
	Audio,
	BackgroundMusic,
	
	#Godot Events
	EmitSignal,
	ChangeScene,
	CallNode
}

## *****************************************************************************
##								INITIALIZATION
## *****************************************************************************
func _init() -> void:
	var directory = Directory.new()
	
	var user_dir = GDialog_Resources.working_dirs["USER_DIR"]
	
	if not directory.dir_exists(user_dir):
		directory.make_dir_recursive(user_dir)
		
	GDialog_Resources.create_empty_files(directory, GDialog_Resources.user_files)

	var res_values = GDialog_Resources.load_res_values()
	
	var user_values = GDialog_Resources.load_user_values()
	
	for value_name in res_values:
		values[value_name] = {"default":res_values[value_name]}
		
		var current_value
		
		if user_values.has(value_name):
			current_value = user_values[value_name]
		else:
			current_value = res_values[value_name]
			
		values[value_name]["current"] = current_value
	
	timelines = GDialog_Resources.load_timelines()
	
	characters = GDialog_Resources.load_characters()
	
	current_state = GDialog_Resources.get_saved_state()
	
	#current_timeline = get_saved_state_general_key('timeline')

func init(reset: bool=false) -> void:
	pass
#	if reset and autosave:
#		# Loads saved definitions into memory
#		GDialog_Resources.init_saves()
#	default_definitions = GDialog_Resources.get_default_definitions()
#	current_definitions = GDialog_Resources.get_saved_definitions(default_definitions)
#	current_state = GDialog_Resources.get_saved_state()
#	current_timeline = get_saved_state_general_key('timeline')


## *****************************************************************************
##						DEFINITIONS: VARIABLES/GLOSSARY
## *****************************************************************************

func get_definitions_list() -> Array:
	return GDialog_DefinitionsUtil.definitions_json_to_array(current_definitions)


func get_definitions() -> Dictionary:
	return current_definitions


func get_default_definitions() -> Dictionary:
	return default_definitions


func get_default_definitions_list() -> Array:
	return GDialog_DefinitionsUtil.definitions_json_to_array(default_definitions)


func save_definitions():
	if autosave:
		return GDialog_Resources.save_saved_definitions(current_definitions)
	else:
		return OK

## Return the default or current value with the given name.
## The returned value is a String or a float
## using Godot built-in methods: 
## [`is_valid_float`](https://docs.godotengine.org/en/stable/classes/class_string.html#class-string-method-is-valid-float)
## [`float()`](https://docs.godotengine.org/en/stable/classes/class_float.html#class-float-method-float).
##
## @param value_name	The name of the value to return.
## @param default	if true return default value, else current
## @returns		The value as string or float.
func get_value(value_name:String, default:bool = false):
	var value0 = values[value_name]
	
	var value:String = value0["default"] if default else value0["current"]
	
	if value.is_valid_float():
		return float(value)
		
	return value

## Sets the value with the given name.
## The given value will be converted to string using the 
## [`str()`](https://docs.godotengine.org/en/stable/classes/class_string.html) function.
##
## @param name					The name of the value to edit.
## @param value					The value to set.
func set_value(value_name:String, value):
	values[value_name]["current"] = str(value)

func get_glossary(name: String) -> Dictionary:
	for d in current_definitions['glossary']:
		if d['name'] == name:
			return d
	return { 
		'title': '',
		'text': '',
		'extra': ''
	}

func set_glossary(name: String, title: String, text: String, extra: String) -> void:
	for d in current_definitions['glossary']:
		if d['name'] == name:
			d['title'] = title
			d['text'] = text
			d['extra'] = extra


func set_glossary_from_id(id: String, title: String, text: String, extra:String) -> void:
	var target_def: Dictionary;
	for d in current_definitions['glossary']:
		if d['id'] == id:
			target_def = d;
	if target_def != null:
		if title and title != "[No Change]":
			target_def['title'] = title
		if text and text != "[No Change]":
			target_def['text'] = text
		if extra and extra != "[No Change]":
			target_def['extra'] = extra


## *****************************************************************************
##								TIMELINES
## *****************************************************************************

## Starts the dialog for the given timeline and returns a Dialog node.
## You must then add it manually to the scene to display the dialog.
##
## Example:
## var new_dialog = GDialog.start("Your Timeline Name Here")
## add_child(new_dialog)
##
## This is exactly the same as using the editor:
## you can drag and drop the scene located at /addons/GDialog/Dialog.tscn 
## and set the current timeline via the inspector.
##
## @param timeline				The timeline to load. You can provide the timeline name or the filename.
## @param reset_saves			True to reset GDialog saved data such as definitions.
## @param dialog_scene_path		If you made a custom Dialog scene or moved it from its default path, you can specify its new path here.
## @param debug_mode			Debug is disabled by default but can be enabled if needed.
## @param use_canvas_instead	Create the Dialog inside a canvas layer to make it show up regardless of the camera 2D/3D situation.
## @returns						A Dialog node to be added into the scene tree.
func start(timeline_name: String, reset_saves: bool=true, dialog_scene_path: String="res://addons/GDialog/Dialog.tscn", debug_mode: bool=false, use_canvas_instead=true):
	var dialog_scene = load(dialog_scene_path)
	var dialog_node = null
	var canvas_dialog_node = null
	var returned_dialog_node = null
	
	if use_canvas_instead:
		var canvas_dialog_script = load("res://addons/GDialog/Nodes/canvas_dialog_node.gd")
		canvas_dialog_node = canvas_dialog_script.new()
		canvas_dialog_node.set_dialog_node_scene(dialog_scene)
		dialog_node = canvas_dialog_node.dialog_node
	else:
		dialog_node = dialog_scene.instance()
	
	dialog_node.reset_saves = reset_saves
	dialog_node.debug_mode = debug_mode
	
	returned_dialog_node = dialog_node if not canvas_dialog_node else canvas_dialog_node
	
	if !timeline_name.empty() and timelines.has(timeline_name):
		dialog_node.timeline_name = timeline_name
		
		return returned_dialog_node
	
	dialog_node.dialog_script = {
		"events":[
			{"type": Event_Type.Text,
			"character":"",
			"portrait":"",
			"text":"[Dialogic Error] Loading dialog [color=red]" + timeline_name + "[/color]. It seems like the timeline doesn't exists. Maybe the name is wrong?"
		}]}
		
	return returned_dialog_node

## Same as the start method above, but using the last timeline saved.
## 
## @param initial_timeline		The timeline to load in case no save is found.
## @param dialog_scene_path		If you made a custom Dialog scene or moved it from its default path, you can specify its new path here.
## @param debug_mode			Debug is disabled by default but can be enabled if needed.
## @returns						A Dialog node to be added into the scene tree.
func start_from_save(initial_timeline: String, dialog_scene_path: String="res://addons/GDialog/Dialog.tscn", debug_mode: bool=false):
	var current := get_current_timeline()
	if current.empty():
		current = initial_timeline
	return start(current, false, dialog_scene_path, debug_mode)

## Sets the currently saved timeline.
## Use this if you disabled current timeline autosave and want to control it yourself
##
## @param timelinie						The new timeline to save.
func set_current_timeline(timeline: String):
	current_timeline = timeline
	set_saved_state_general_key('timeline', timeline)

## Gets the currently saved timeline.
## Timeline saves are set on timeline start, and cleared on end.
## This means you can keep track of timeline changes and detect when the dialog ends.
##
## @returns						The current timeline filename, or an empty string if none was saved.
func get_current_timeline() -> String:
	return current_timeline


## *****************************************************************************
##								SAVE STATE
## *****************************************************************************

func get_saved_state_general_key(key: String) -> String:
	if key in current_state['general'].keys():
		return current_state['general'][key]
	else:
		return ''


func set_saved_state_general_key(key: String, value) -> void:
	current_state['general'][key] = str(value)
	save_state()

func save_state():
	if autosave:
		return GDialog_Resources.save_saved_state_config(current_state)
	else:
		return OK

## *****************************************************************************
##								AUTOSAVE
## *****************************************************************************

func get_autosave() -> bool:
	return autosave;


func set_autosave(save: bool):
	autosave = save;


## *****************************************************************************
##								IMPORT/EXPORT
## *****************************************************************************

func export() -> Dictionary:
	return {
		'definitions': current_definitions,
		'state': current_state,
	}

func import(data: Dictionary) -> void:
	init(false);
	current_definitions = data['definitions'];
	current_state = data['state'];
	current_timeline = get_saved_state_general_key('timeline')
