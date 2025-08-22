extends "classes/crushing.gd"

signal generic

@export var message: String = ""

@export_node_path("AnimationPlayer") var _animation_player: NodePath
@onready var animation_player: AnimationPlayer = get_node(_animation_player)

@export_node_path("Timer") var _delay_timer: NodePath
@onready var delay_timer: Timer = get_node(_delay_timer)

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node_or_null(_wait_timer)

@export var max_health: int = 1
@onready var quake_health: int = max_health:
	set(value):
		var previous_health := int(quake_health)
		quake_health = clampi(value, 0, max_health)
		if quake_health == 0 and quake_health != previous_health:
			_on_activated()

@export var open_once: bool = false


func _on_activated() -> void:
	animation_player.play("open")
	_message(message)
	generic.emit()


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == "open":
		animation_player.play("opened")
		if is_instance_valid(wait_timer):
			wait_timer.start()
	elif animation_name == "close":
		animation_player.play("closed")
		quake_health = max_health

@warning_ignore("unused_parameter", "shadowed_variable")
func _on_crushing(object: Object, damage: int) -> void:
	if not delay_timer.is_stopped():
		return
	var time := animation_player.current_animation_position
	animation_player.play_backwards(animation_player.current_animation)
	animation_player.seek(time)
	delay_timer.start()

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


func _on_wait_timer_timeout() -> void:
	if not open_once:
		animation_player.play("close")


func _on_delay_timer_timeout() -> void:
	var time := animation_player.current_animation_position
	animation_player.play(animation_player.current_animation)
	animation_player.seek(time)

@warning_ignore("shadowed_variable")
func _crush(object: Object, damage: int) -> void:
	if object.has_method("_quake_crush"):
		object.call("_quake_crush", self, damage)

@warning_ignore("shadowed_variable")
func _message(message: String) -> void:
	if not message.is_empty():
		print(message)
