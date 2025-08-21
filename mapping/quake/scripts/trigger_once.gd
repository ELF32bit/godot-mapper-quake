extends Area3D

signal generic

@export var message: String = ""

@export_node_path("Timer") var _delay_timer: NodePath
@onready var delay_timer: Timer = get_node_or_null(_delay_timer)

@export_node_path("AudioStreamPlayer3D") var _trigger_sound_player: NodePath
@onready var trigger_sound_player: AudioStreamPlayer3D = get_node(_trigger_sound_player)

var has_fired := false

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node3D) -> void:
	# ignoring same events on the same frame
	if has_fired:
		return
	# disabling area at the end of the frame
	set_deferred("monitoring", false)
	has_fired = true
	_on_trigger_fired()


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
	_on_body_entered(null)

@warning_ignore("shadowed_variable")
func _message(message: String) -> void:
	if not message.is_empty():
		print(message)
