extends Node

## Exposed and safe to use methods for Dialogic
## See documentation here:
## https://github.com/coppolaemilio/GDialog

## ### /!\ ###
## Do not use methods from other classes as it could break the plugin's integrity
## ### /!\ ###
##
## Trying to follow this documentation convention: https://github.com/godotengine/godot/pull/41095
class_name GDialog_Class

## Gets default values for definitions.
## 
## @returns						Dictionary in the format {'variables': [], 'glossary': []}
static func get_default_definitions() -> Dictionary:
	return GDialog.get_default_definitions()


## Gets currently saved values for definitions.
## 
## @returns						Dictionary in the format {'variables': [], 'glossary': []}
static func get_definitions() -> Dictionary:
	return GDialog.get_definitions()


## Save current definitions to the filesystem.
## Definitions are automatically saved on timeline start/end
## 
## @returns						Error status, OK if all went well
static func save_definitions():
	# Always try to save as much as possible.
	var err1 = GDialog.save_definitions()
	var err2 = GDialog.save_state()

	# Try to combine the two error states in a way that makes sense.
	return err1 if err1 != OK else err2


## Sets whether to use Dialogic's built-in autosave functionality.
static func set_autosave(save: bool) -> void:
	GDialog.set_autosave(save);


## Gets whether to use Dialogic's built-in autosave functionality.
static func get_autosave() -> bool:
	return GDialog.get_autosave();


## Resets data to default values. This is the same as calling start with reset_saves to true
static func reset_saves():
	GDialog.init(true)

## Gets the glossary data for the definition with the given name.
## Returned format:
## { title': '', 'text' : '', 'extra': '' }
##
## @param name					The name of the glossary to find.
## @returns						The glossary data as a Dictionary.
## 								A structure with empty strings is returned if the glossary was not found. 
static func get_glossary(name: String) -> Dictionary:
	return GDialog.get_glossary(name)


## Sets the data for the glossary of the given name.
## 
## @param name					The name of the glossary to edit.
## @param title					The title to show in the information box.
## @param text					The text to show in the information box.
## @param extra					The extra information at the bottom of the box.
static func set_glossary(name: String, title: String, text: String, extra: String) -> void:
	GDialog.set_glossary(name, title, text, extra)

## Export the current Dialogic state.
## This can be used as part of your own saving mechanism if you have one. If you use this,
## you should also disable autosaving.
##
## @return						A dictionary of data that can be later provided to import().
static func export() -> Dictionary:
	if Engine.is_editor_hint():
		return Engine.get_singleton('GDialog').export()
	else:
		var cursed_singleton
		if Engine.has_singleton('GDialog'):
			cursed_singleton = Engine.get_singleton('GDialog')
			return cursed_singleton.export()
		else:
			return {}


## Import a Dialogic state.
## This can be used as part of your own saving mechanism if you have one. If you use this,
## you should also disable autosaving.
##
## @param data				A dictionary of data as created by export().
static func import(data: Dictionary) -> void:
	if Engine.is_editor_hint():
		Engine.get_singleton('GDialog').import(data)
	else:
		var cursed_singleton
		if Engine.has_singleton('GDialog'):
			cursed_singleton = Engine.get_singleton('GDialog')
			cursed_singleton.import(data)
