@tool
extends Node

@export var monster_name: String = ""
var animation_player: AnimationPlayer


func _ready() -> void:
	animation_player = get_node("AnimationPlayer")
	match monster_name:
		"army":
			animation_player.current_animation = "stand"
		"dog":
			animation_player.current_animation = "stand"
		"ogre":
			animation_player.current_animation = "stand"
		"ogre_marksman":
			animation_player.current_animation = "stand"
		"knight":
			animation_player.current_animation = "stand"
		"hell_knight":
			animation_player.current_animation = "stand"
		"wizard":
			animation_player.current_animation = "hover"
		"demon1":
			animation_player.current_animation = "stand"
		"shambler":
			animation_player.current_animation = "stand"
		"boss":
			animation_player.current_animation = "walk"
		"enforcer":
			animation_player.current_animation = "stand"
		"shalrath":
			animation_player.current_animation = "walk"
		"tarbaby":
			animation_player.current_animation = "walk"
		"fish":
			animation_player.current_animation = "swim"
		"oldone":
			animation_player.current_animation = "old"
		"zombie":
			animation_player.current_animation = "stand"
		_:
			return
	animation_player.animation_finished.connect(_on_animation_finished)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_player:
		animation_player.current_animation = animation_name
