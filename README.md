# Godot_Dialog
![Godot v3.3](https://img.shields.io/badge/godot-v3.3-informational?style=flat-square&logo=godotengine)
A powerful plugin to easily create interactive dialogs, for your visual novels, rpgs, or other game in Godot-Engine.

Works in 2D and 3D.

Complete solution with visual editor to edit dialog's themes, timelines, characters, and saved values.

[Installation](#installation) —
[FAQ](#faq) — 
[Credits](#credits)

---

## Installation

To install Godot_Dialog plugin, download it as a [ZIP archive](https://github.com/theludovyc/Godot_Dialogic/releases). Then extract the `addons/GDialog` folder into your project folder. Then, enable the plugin in project settings and restart Godot-Engine.

If you want to know more about installing plugins you can read the [official documentation page](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html).

## ⚠ IMPORTANT
The Godot editor needs a reboot after enabling GDialog for the first time. So make sure to reboot after activating it for the first time before submitting an issue.


## 📦 Export

When you export a project using GDialog, you need to add `*.json, *.cfg` on the Resources tab `Filters to export...` input field. This allows Godot to pack the files from the `/GDialog` folder.

## Get Started
There are two ways of doing this; using gdscript or the scene editor.

Using the `GDialog` singleton you can add dialogs from code easily:

```gdscript
var new_dialog = GDialog.start("Your Timeline Name Here")

add_child(new_dialog)
```

And using the editor, you can drag and drop the scene located at `/addons/GDialog/Dialog.tscn` and set the current timeline via the inspector.

For further informations see this [wiki](https://github.com/theludovyc/Godot_Dialog/wiki).

---

## FAQ
### 🔷 Can I use GDialog in one of my projects?
Yes, you can use GDialog to make any kind of game (even commercial ones). The project is developed under the [MIT License](https://github.com/theludovyc/Godot_Dialogic/blob/master/LICENSE). Please remember to credit!

### 🔷 My resolution is too small and the dialog is too big. Help!
If you are setting the resolution of your game to a very small value, you will have to create a theme in GDialog and pick a smaller font and make the box size of the Dialog Box smaller as well.

### 🔷 How do I connect signals?
Signals work the same way as in any Godot node. If you are new to gdscript you should watch this video which cover how Godot signals work: [How to Use Godot's Signals](https://www.youtube.com/watch?v=NK_SYVO7lMA).

Every event emits a signal called `event_start` when GDialog starts that event's actions, but there are also two other named signals called `timeline_start(timeline_name)` and `timeline_end(timeline_name)` which are called at the start and at the end respectively.

Here you have a small snippet of how to connect a GDialog signal:
```gdscript
# Example for timeline_end
func _ready():
	var new_dialog = GDialog.start('Your Timeline Name Here')
	
	add_child(new_dialog)
	
	new_dialog.connect('timeline_end', self, 'after_dialog')

func after_dialog(timeline_name):
	print('Now you can resume with the game :)')
```

### 🔷 Can I create a dialog using GDScript?
Yes! it is a bit harder since you will have to create each event yourself, and to do that they have to be valid. You can check already created timelines with a text editor and see how an event should look like. A better tutorial and improvements will come soon.

A simple example:
```gdscript
func _ready():
	var gdscript_dialog = GDialog.start("")
	
	gdscript_dialog.set_dialog_script( {
		"events":[
			{ "type":GDialog.Event_Type.Text, "text": "This dialog was created using GDScript!"}
		]
	})
	
	add_child(gdscript_dialog)
```

---

## Credits
Initial project [dialogic](https://github.com/coppolaemilio/dialogic) made by [Emilio Coppola](https://github.com/coppolaemilio)

My incredible tester https://github.com/LauraCrossheart
