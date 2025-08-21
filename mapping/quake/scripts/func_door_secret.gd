extends "classes/crushing.gd"

signal generic

@export var message: String = ""

@export_node_path("AnimationPlayer") var _animation_player: NodePath
@onready var animation_player: AnimationPlayer = get_node(_animation_player)

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node_or_null(_wait_timer)

@export var max_health: int = 1
@onready var quake_health: int = max_health:
	set(value):
		var previous_health := int(quake_health)
		quake_health = clampi(value, 0, max_health)
		if quake_health == 0 and quake_health != previous_health:
			generic.emit()


@warning_ignore("unused_parameter", "shadowed_variable")
func _on_crushing(object: Object, damage: int) -> void:
	pass

@warning_ignore("shadowed_variable")
func _on_crushing_object(object: Object, damage: int) -> void:
	if is_instance_valid(object):
		_crush(object, damage)
	_on_crushing(object, damage)

@warning_ignore("shadowed_variable")
func _on_crushing_character(character: CharacterBody3D, damage: int) -> void:
	if is_instance_valid(character):
		_crush(character, damage)
	_on_crushing(character, damage)

@warning_ignore("shadowed_variable")
func _crush(object: Object, damage: int) -> void:
	if object.has_method("_quake_crush"):
		object.call("_quake_crush", self, damage)

@warning_ignore("shadowed_variable")
func _message(message: String) -> void:
	if not message.is_empty():
		print(message)
