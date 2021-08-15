extends Node

## This script is added as an AutoLoad when the plugin is activated
## It is used during game execution to access the dialogic resources

## Mainly it's used by the dialog_node.gd and the DialogicClass
## In your game you should consider using the methods of the DialogicClass!

var current_definitions := {}
var default_definitions := {}

var values:Dictionary

var timelines:Dictionary

var current_state := {}
var autosave := true

var current_timeline := ''

enum Event_Type{
	#Main Events
	Text=0,
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
	
	var user_dir = DialogicResources.working_dirs["USER_DIR"]
	
	if not directory.dir_exists(user_dir):
		directory.make_dir_recursive(user_dir)
		
	DialogicResources.create_empty_files(directory, DialogicResources.user_files)

	var res_values = DialogicResources.load_res_values()
	
	var user_values = DialogicResources.load_user_values()
	
	for value_name in res_values:
		values[value_name] = {"default":res_values[value_name]}
		
		var current_value
		
		if user_values.has(value_name):
			current_value = user_values[value_name]
		else:
			current_value = res_values[value_name]
			
		values[value_name]["current"] = current_value
	
	timelines = DialogicResources.load_timelines()
	
	current_state = DialogicResources.get_saved_state()
	
	#current_timeline = get_saved_state_general_key('timeline')

func init(reset: bool=false) -> void:
	pass
#	if reset and autosave:
#		# Loads saved definitions into memory
#		DialogicResources.init_saves()
#	default_definitions = DialogicResources.get_default_definitions()
#	current_definitions = DialogicResources.get_saved_definitions(default_definitions)
#	current_state = DialogicResources.get_saved_state()
#	current_timeline = get_saved_state_general_key('timeline')


## *****************************************************************************
##						DEFINITIONS: VARIABLES/GLOSSARY
## *****************************************************************************

func get_definitions_list() -> Array:
	return DialogicDefinitionsUtil.definitions_json_to_array(current_definitions)


func get_definitions() -> Dictionary:
	return current_definitions


func get_default_definitions() -> Dictionary:
	return default_definitions


func get_default_definitions_list() -> Array:
	return DialogicDefinitionsUtil.definitions_json_to_array(default_definitions)


func save_definitions():
	if autosave:
		return DialogicResources.save_saved_definitions(current_definitions)
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

func set_current_timeline(timeline: String):
	current_timeline = timeline
	set_saved_state_general_key('timeline', timeline)


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
		return DialogicResources.save_saved_state_config(current_state)
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
