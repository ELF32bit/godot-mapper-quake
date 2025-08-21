extends StaticBody3D

signal generic

@export var message: String = ""

@export_node_path("AudioStreamPlayer3D") var _trigger_sound_player: NodePath
@onready var trigger_sound_player: AudioStreamPlayer3D = get_node(_trigger_sound_player)

@export var delay_time: float = 0.0

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node_or_null(_wait_timer)

@export var max_health: int = 1
@onready var quake_health: int = max_health:
	set(value):
		var previous_health := int(quake_health)
		quake_health = clampi(value, 0, max_health)
		if quake_health == 0 and quake_health != previous_health:
			_on_trigger_fired()


func _on_trigger_fired() -> void:
	# checking trigger timer before starting
	if is_instance_valid(wait_timer):
		wait_timer.start()
	# starting possibly multiple delay timers at runtime
	_start_delay_timer(delay_time)
	# playing trigger sound without delay
	trigger_sound_player.play()


func _on_wait_timer_timeout() -> void:
	quake_health = max_health


func _on_delay_timer_timeout() -> void:
	_message(message)
	generic.emit()


func _on_generic_signal() -> void:
	quake_health = 0

@warning_ignore("shadowed_variable")
func _start_delay_timer(delay_time: float) -> void:
	if delay_time < 0.0:
		return
	# creating safe timer and connecting signals
	var delay_timer := Timer.new()
	delay_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	delay_timer.timeout.connect(_on_delay_timer_timeout)
	delay_timer.timeout.connect(delay_timer.queue_free)
	delay_timer.wait_time = clampf(delay_time, 0.05, INF)
	delay_timer.one_shot = true
	# starting timer inside scene tree
	add_child(delay_timer, false)
	delay_timer.start()

@warning_ignore("shadowed_variable")
func _message(message: String) -> void:
	if not message.is_empty():
		print(message)
