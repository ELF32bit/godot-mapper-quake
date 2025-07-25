@tool
extends Node

@export var monster_name: String = ""
var animation_player: AnimationPlayer = null


func _ready() -> void:
	animation_player = get_child(0)
	match monster_name:
		"monster_army": # grunt
			_enable_animation("stand")
		"monster_dog": # nasty doggie
			_enable_animation("stand")
		"monster_ogre": # ogre
			_enable_animation("stand")
		"monster_ogre_marksman": # ogre marksman
			_enable_animation("stand")
		"monster_knight": # knight
			_enable_animation("stand")
		"monster_hell_knight": # hell knight
			_enable_animation("stand")
		"monster_wizard": # scrag
			_enable_animation("hover")
		"monster_demon1": # fiend
			_enable_animation("stand")
		"monster_shambler": # shambler
			_enable_animation("stand")
		"monster_boss": # chthon
			_enable_animation("walk")
		"monster_enforcer": # enforcer
			_enable_animation("stand")
		"monster_shalrath": # vore
			_enable_animation("walk")
		"monster_tarbaby": # spawn
			_enable_animation("walk")
		"monster_fish": # rotfish
			_enable_animation("swim")
		"monster_oldone": # shub-niggurath
			_enable_animation("old")
		"monster_zombie": # zombie
			_enable_animation("stand")
		"player":
			_enable_animation("stand")
		_:
			return


func _enable_animation(animation_name: StringName) -> void:
	var animation := animation_player.get_animation(animation_name)
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play(animation_name)
