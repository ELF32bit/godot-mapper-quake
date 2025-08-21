extends StaticBody3D

signal generic

@export var message: String = ""

@export_node_path("Timer") var _delay_timer: NodePath
@onready var delay_timer: Timer = get_node_or_null(_delay_timer)

@export_node_path("AudioStreamPlayer3D") var _trigger_sound_player: NodePath
@onready var trigger_sound_player: AudioStreamPlayer3D = get_node(_trigger_sound_player)

@export var max_health: int = 0
@onready var quake_health: int = max_health:
	set(value):
		if has_fired:
			return
		var previous_health := int(quake_health)
		quake_health = clampi(value, 0, max_health)
		if quake_health == 0 and quake_health != previous_health:
			has_fired = true
			_on_trigger_fired()

var has_fired := false


func _on_trigger_fired() -> void:
	# checking trigger timer before starting
	if is_instance_valid(delay_timer):
		delay_timer.start()
	# playing trigger sound without delay
	trigger_sound_player.play()


func _on_delay_timer_timeout() -> void:
	_message(message)
	generic.emit()


func _on_generic_signal() -> void:
	quake_health = 0

@warning_ignore("shadowed_variable")
func _message(message: String) -> void:
	if not message.is_empty():
		print(message)
