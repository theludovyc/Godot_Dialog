tool
class_name GDialog_Resources

## This class is used by the DialogicEditor to access the resources files
## For example by the Editors (Timeline, Character, Theme), the MasterTree and the EventParts

## It is also used by the GDialog_Util class and the GDialog singleton

const RESOURCES_DIR: String = "res://GDialog" # Readonly, used for static data
const USER_DIR: String = "user://GDialog" # Readwrite, used for saves

const working_dirs = {
		'RESOURCES_DIR': RESOURCES_DIR,
		'USER_DIR': USER_DIR,
		'TIMELINE_DIR': RESOURCES_DIR + "/timelines",
		'THEME_DIR': RESOURCES_DIR + "/themes",
		'CHAR_DIR': RESOURCES_DIR + "/characters",
	}
	
const cfg_files = {
		'SETTINGS_FILE': RESOURCES_DIR + "/settings.cfg",
		'DEFAULT_DEFINITIONS_FILE': RESOURCES_DIR + "/definitions.json",
		'RES_VALUES_FILE' : RESOURCES_DIR + "/values.json",
		'FOLDER_STRUCTURE_FILE': RESOURCES_DIR + "/folder_structure.json",
	}
	
const user_files = {
	"USER_VALUES" : USER_DIR + "/values.json",
	'SAVED_DEFINITIONS_FILE': USER_DIR + "/definitions.json",
	"STATE": USER_DIR + "/state.json"
}

## *****************************************************************************
##							BASIC JSON FUNCTION
## *****************************************************************************
static func load_json(path: String, default: Dictionary={}) -> Dictionary:
	# An easy function to load json files and handle common errors.
	var file := File.new()
	if file.open(path, File.READ) != OK:
		file.close()
		return default
	var data_text: String = file.get_as_text()
	file.close()
	if data_text.empty():
		return default
	var data_parse: JSONParseResult = JSON.parse(data_text)
	if data_parse.error != OK:
		return default

	var final_data = data_parse.result
	if typeof(final_data) == TYPE_DICTIONARY:
		return final_data
	
	# If everything else fails
	return default

static func load_jsons(dirPath:String) -> Dictionary:
	var dic:Dictionary
	
	var dir := Directory.new()
	
	if dir.open(dirPath) == OK:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		
		while file_name != "":
			if !dir.current_is_dir():
				var name = file_name.rstrip(".json")
				
				dic[name] = load_json(dirPath + "/" + file_name)
				
			file_name = dir.get_next()

	return dic

static func save_json(path: String, data: Dictionary):
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if err == OK:
		file.store_line(JSON.print(data, "\t", true))
		file.close()
	return err

static func rename_json(folderPath:String, oldName:String, newName:String):
	var dir := Directory.new()
	
	dir.rename(get_path(folderPath, oldName + ".json"), get_path(folderPath, newName + ".json"))

## *****************************************************************************
##							INITIALIZATION
## *****************************************************************************

#static func get_working_directories() -> Dictionary:
#	return {
#		'RESOURCES_DIR': RESOURCES_DIR,
#		'USER_DIR': USER_DIR,
#		'TIMELINE_DIR': RESOURCES_DIR + "/timelines",
#		'THEME_DIR': RESOURCES_DIR + "/themes",
#		'CHAR_DIR': RESOURCES_DIR + "/characters",
#	}


#static func get_config_files_paths() -> Dictionary:
#	return {
#		'SETTINGS_FILE': RESOURCES_DIR + "/settings.cfg",
#		'DEFAULT_DEFINITIONS_FILE': RESOURCES_DIR + "/definitions.json",
#		'RES_VARIABLES_FILE' : RESOURCES_DIR + "/variables.json",
#		'FOLDER_STRUCTURE_FILE': RESOURCES_DIR + "/folder_structure.json",
#		'SAVED_DEFINITIONS_FILE': USER_DIR + "/definitions.json",
#		'SAVED_STATE_FILE': USER_DIR + "/state.json",
#	}

static func init_saves():
	var err = init_working_dir()
	var paths := cfg_files

	if err == OK:
		init_state_saves()
		init_definitions_saves()
	else:
		print('[Dialogic] Error creating working directory: ' + str(err))


static func init_working_dir():
	var directory := Directory.new()
	return directory.make_dir_recursive(working_dirs['USER_DIR'])


static func init_state_saves():
	var file := File.new()
	var paths := cfg_files
	var err = file.open(paths["SAVED_STATE_FILE"], File.WRITE)
	if err == OK:
		file.store_string('')
		file.close()
	else:
		print('[Dialogic] Error opening saved state file: ' + str(err))


static func init_definitions_saves():
	var directory := Directory.new()
	var source := File.new()
	var sink := File.new()
	var paths := cfg_files
	var err = sink.open(paths["SAVED_DEFINITIONS_FILE"], File.WRITE)
	print('[Dialogic] Initializing save file: ' + str(err))
	if err == OK:
		sink.store_string('')
		sink.close()
	else:
		print('[Dialogic] Error opening saved definitions file: ' + str(err))

	err = sink.open(paths["SAVED_DEFINITIONS_FILE"], File.READ_WRITE)
	if err == OK:
		err = source.open(paths["DEFAULT_DEFINITIONS_FILE"], File.READ)
		if err == OK:
			sink.store_string(source.get_as_text())
		else:
			print('[Dialogic] Error opening default definitions file: ' + str(err))
	else:
		print('[Dialogic] Error opening saved definitions file: ' + str(err))
	
	source.close()
	sink.close()


## *****************************************************************************
##							BASIC FILE FUNCTION
## *****************************************************************************

static func get_path(name: String, extra: String ='') -> String:
	var paths: Dictionary = working_dirs
	if extra != '':
		return paths[name] + '/' + extra
	else:
		return paths[name]


static func get_filename_from_path(path: String, extension = false) -> String:
	var file_name: String = path.split('/')[-1]
	if extension == false:
		file_name = file_name.split('.')[0]
	return file_name


static func listdir(path: String) -> Array:
	# https://docs.godotengine.org/en/stable/classes/class_directory.html#description
	var files: Array = []
	var dir := Directory.new()
	var err = dir.open(path)
	if err == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and not file_name.begins_with("."):
				files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("[Dialogic] Error while accessing path " + path + " - Error: " + str(err))
	return files


static func create_empty_file(path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string('')
	file.close()

static func create_empty_files(directory:Directory, files:Dictionary):
	for f in files:
		if not directory.file_exists(files[f]):
			create_empty_file(files[f])

static func remove_file(path: String):
	var dir = Directory.new()
	var _err = dir.remove(path)
	
	if _err != OK:
		print("[D] There was an error when deleting file at {filepath}. Error: {error}".format(
			{"filepath":path,"error":_err}
		))


static func copy_file(path_from, path_to):
	if (path_from == ''):
		push_error("[Dialogic] Could not copy empty filename")
		return ERR_FILE_BAD_PATH
		
	if (path_to == ''):
		push_error("[Dialogic] Could not copy to empty filename")
		return ERR_FILE_BAD_PATH
	
	var dir = Directory.new()
	if (not dir.file_exists(path_from)):
		push_error("[Dialogic] Could not copy file %s, File does not exists" % [ path_from ])
		return ERR_FILE_NOT_FOUND
		
	if (dir.file_exists(path_to)):
		push_error("[Dialogic] Could not copy file to %s, file already exists" % [ path_to ])
		return ERR_ALREADY_EXISTS
		
	var error = dir.copy(path_from, path_to)
	if (error):
		push_error("[Dialogic] Error while copying %s to %s" % [ path_from, path_to ])
		push_error(error)
		return error
		
	return OK
	pass

## *****************************************************************************
##							CONFIG
## *****************************************************************************


static func get_config(id: String) -> ConfigFile:
	var paths := cfg_files
	var config := ConfigFile.new()
	if id in paths.keys():
		var err = config.load(paths[id])
		if err != OK:
			print("[Dialogic] Error while opening config file " + paths[id] + ". Error: " + str(err))
	return config



## *****************************************************************************
##							TIMELINES
## *****************************************************************************
# Can only be edited in the editor

static func get_timeline_json(path: String):
	return load_json(get_path('TIMELINE_DIR', path))

static func load_timelines() -> Dictionary:
	var dic:Dictionary
	
	var dir := Directory.new()
	
	if dir.open(working_dirs["TIMELINE_DIR"]) == OK:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		
		while file_name != "":
			if !dir.current_is_dir():
				var timeline_name = file_name.rstrip(".json")
				
				dic[timeline_name] = load_json(get_path('TIMELINE_DIR', file_name))
				
				#event_type is int but parse make it float
				var events = dic[timeline_name]["events"]
				
				if !events.empty():
					for event in events:
						event["type"] = int(event["type"])
				
			file_name = dir.get_next()

	return dic

static func save_timeline(name:String, data:Dictionary):
	save_json(get_path("TIMELINE_DIR", name + ".json"), data)

static func delete_timeline(name: String):
	remove_file(get_path('TIMELINE_DIR', name + ".json"))

static func rename_timeline(oldName:String, newName:String):
	rename_json("TIMELINE_DIR", oldName, newName)

## *****************************************************************************
##							CHARACTERS
## *****************************************************************************
static func load_characters() -> Dictionary:
	return load_jsons(working_dirs["CHAR_DIR"])

static func rename_character(oldName:String, newName:String):
	rename_json("CHAR_DIR", oldName, newName)

static func get_character_json(path: String):
	return load_json(get_path('CHAR_DIR', path))

static func save_character(name, data:Dictionary):
	save_json(get_path('CHAR_DIR', name + ".json"), data)

static func delete_character(name:String):
	remove_file(get_path('CHAR_DIR', name + ".json"))


## *****************************************************************************
##							THEMES
## *****************************************************************************
# Can only be edited in the editor

static func get_theme_config(filename: String):
	var config = ConfigFile.new()
	var path
	if filename.begins_with('res://'):
		path = filename
	else:
		path = get_path('THEME_DIR', filename)
	var err = config.load(path)
	if err == OK:
		return config


static func set_theme_value(filename, section, key, value):
	# WARNING: For use in the editor only
	var config = get_theme_config(filename)
	config.set_value(section, key, value)
	config.save(get_path('THEME_DIR', filename))


static func add_theme(filename: String):
	create_empty_file(get_path('THEME_DIR', filename))


static func delete_theme(filename: String):
	remove_file(get_path('THEME_DIR', filename))
	
	
static func duplicate_theme(from_filename: String, to_filename: String):
	copy_file(get_path('THEME_DIR', from_filename), get_path('THEME_DIR', to_filename))

## *****************************************************************************
##							SETTINGS
## *****************************************************************************
# Can only be edited in the editor


static func get_settings_config() -> ConfigFile:
	return get_config("SETTINGS_FILE")


static func set_settings_value(section: String, key: String, value):
	var config = get_settings_config()
	config.set_value(section, key, value)
	config.save(cfg_files['SETTINGS_FILE'])


## *****************************************************************************
##							STATE
## *****************************************************************************
static func get_saved_state() -> Dictionary:
	return load_json(user_files["STATE"], {'general': {}})

static func save_saved_state_config(data: Dictionary):
	save_json(user_files["STATE"], data)

## *****************************************************************************
##						RES VALUES
## *****************************************************************************
# Can only be edited in the editor

static func load_res_values() -> Dictionary:
	return load_json(cfg_files['RES_VALUES_FILE'])
	
static func save_res_values(data: Dictionary):
	save_json(cfg_files['RES_VALUES_FILE'], data)

## *****************************************************************************
##						USER VALUES
## *****************************************************************************
static func load_user_values() -> Dictionary:
	return load_json(user_files['USER_VALUES'])
	
static func save_user_values(data: Dictionary):
	save_json(user_files['USER_VALUES'], data)

## *****************************************************************************
##						DEFAULT DEFINITIONS
## *****************************************************************************
# Can only be edited in the editor


static func get_default_definitions() -> Dictionary:
	return load_json(cfg_files['DEFAULT_DEFINITIONS_FILE'])


static func save_default_definitions(data: Dictionary):
	save_json(cfg_files['DEFAULT_DEFINITIONS_FILE'], data)


static func get_default_definition_item(id: String):
	var data = get_default_definitions()
	return GDialog_DefinitionsUtil.get_definition_by_id(data, id)


static func set_default_definition_variable(id: String, name: String, value):
	# WARNING: For use in the editor only
	var data = get_default_definitions()
	GDialog_DefinitionsUtil.set_definition_variable(data, id, name, value)
	save_default_definitions(data)


static func set_default_definition_glossary(id: String, name: String, extra_title: String,  extra_text: String,  extra_extra: String):
	# WARNING: For use in the editor only
	var data = get_default_definitions()
	GDialog_DefinitionsUtil.set_definition_glossary(data, id, name, extra_title, extra_text, extra_extra)
	save_default_definitions(data)


static func delete_default_definition(id: String):
	# WARNING: For use in the editor only
	var data = get_default_definitions()
	GDialog_DefinitionsUtil.delete_definition(data, id)
	save_default_definitions(data)


## *****************************************************************************
##						SAVED DEFINITIONS
## *****************************************************************************
# Can only be edited in the editor

static func get_saved_definitions(default: Dictionary = {'variables': [], 'glossary': []}) -> Dictionary:
	return load_json(cfg_files['SAVED_DEFINITIONS_FILE'], default)


static func save_saved_definitions(data: Dictionary):
	init_working_dir()
	return save_json(cfg_files['SAVED_DEFINITIONS_FILE'], data)

## *****************************************************************************
##						FOLDER STRUCTURE
## *****************************************************************************
# The DialogicEditor uses a fake folder structure
# Can only be edited in the editor

static func get_resource_folder_structure() -> Dictionary:
	return load_json(cfg_files['FOLDER_STRUCTURE_FILE'], 
		{"folders":
			{"Timelines":
				{
					"folders":{},
					"files":[],
					'metadata':{'color':null, 'folded':false}
				},
			"Characters":
				{
					"folders":{},
					"files":[],
					'metadata':{'color':null, 'folded':false}
				},
			"Values":
				{
					"folders":{},
					"files":[],
					'metadata':{'color':null, 'folded':false}
				},
			"Definitions":
				{
					"folders":{},
					"files":[],
					'metadata':{'color':null, 'folded':false}
				},
			"Themes":
				{
					"folders":{},
					"files":[],
					'metadata':{'color':null, 'folded':false}
				},
			}, 
		"files":[]
		})

static func save_resource_folder_structure(data):
	save_json(cfg_files['FOLDER_STRUCTURE_FILE'], data)
	
