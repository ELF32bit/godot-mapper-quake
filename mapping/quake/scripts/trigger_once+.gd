extends StaticBody3D

signal generic

@export var max_health: int = 0
@onready var health: int = max_health:
	set(value):
		if has_fired:
			return
		var previous_health := health
		health = clampi(value, 0, max_health)
		if health != previous_health:
			# health has changed here
			if health == 0:
				has_fired = true
				_on_trigger_fired()

@export var message: String = ""

@export_node_path("Timer") var _delay_timer: NodePath
@onready var delay_timer: Timer = get_node_or_null(_delay_timer)

@export_node_path("AudioStreamPlayer3D") var _trigger_sound_player: NodePath
@onready var trigger_sound_player: AudioStreamPlayer3D = get_node(_trigger_sound_player)

var has_fired := false


func _on_trigger_fired() -> void:
	collision_layer = 0; collision_mask = 0;
	trigger_sound_player.play()
	# checking trigger timer before starting
	if is_instance_valid(delay_timer):
		delay_timer.start()
	print('kek')


func _on_delay_timer_timeout() -> void:
	# can print message here
	generic.emit()


func _on_generic_signal() -> void:
	health = 0
