@tool
extends Node

@export var light_name: String = ""
var animation_player: AnimationPlayer = null


func _ready() -> void:
	animation_player = get_child(0)
	match light_name:
		"light_globe": # globe light
			_enable_animation("frame")
		"light_flame_large_yellow": # large yellow flame
			_enable_animation("flameb")
		"light_flame_small_yellow": # small yellow flame
			_enable_animation("flame")
		"light_flame_small_white": # small white flame
			_enable_animation("flame")
		"light_torch_small_walltorch": # small walltorch
			_enable_animation("flame")


func _enable_animation(animation_name: StringName) -> void:
	var animation := animation_player.get_animation(animation_name)
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play(animation_name)
