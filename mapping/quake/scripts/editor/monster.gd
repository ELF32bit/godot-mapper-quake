@tool
extends Node

@export var monster_name: String = ""
var animation_player: AnimationPlayer = null


func _ready() -> void:
	animation_player = get_child(0)
	match monster_name:
		"army": # grunt
			_enable_animation("stand")
		"dog": # nasty doggie
			_enable_animation("stand")
		"ogre": # ogre
			_enable_animation("stand")
		"ogre_marksman": # ogre marksman
			_enable_animation("stand")
		"knight": # knight
			_enable_animation("stand")
		"hell_knight": # hell knight
			_enable_animation("stand")
		"wizard": # scrag
			_enable_animation("hover")
		"demon1": # fiend
			_enable_animation("stand")
		"shambler": # shambler
			_enable_animation("stand")
		"boss": # chthon
			_enable_animation("walk")
		"enforcer": # enforcer
			_enable_animation("stand")
		"shalrath": # vore
			_enable_animation("walk")
		"tarbaby": # spawn
			_enable_animation("walk")
		"fish": # rotfish
			_enable_animation("swim")
		"oldone": # shub-niggurath
			_enable_animation("old")
		"zombie": # zombie
			_enable_animation("stand")
		"player":
			_enable_animation("stand")
		_:
			return


func _enable_animation(animation_name: StringName) -> void:
	var animation := animation_player.get_animation(animation_name)
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play(animation_name)
