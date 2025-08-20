@tool
extends Node

@export var classname: String = ""
@export var animation_name: String = "":
	set(value):
		_enable_animation(value)
		animation_name = value

var animation_player: AnimationPlayer = null


func _ready() -> void:
	animation_player = get_child(0)
	_enable_animation(animation_name)

@warning_ignore("shadowed_variable")
func _enable_animation(animation_name: StringName) -> void:
	if not is_instance_valid(animation_player):
		return
	if not animation_player.has_animation(animation_name):
		return
	var animation := animation_player.get_animation(animation_name)
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play(animation_name)
