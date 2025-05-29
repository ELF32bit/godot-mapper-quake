extends Node3D

signal generic

@export var delay_time: float = 0.0
@export var message: String = ""

@export_node_path("AudioStreamPlayer3D") var _trigger_sound_player: NodePath
@onready var trigger_sound_player: AudioStreamPlayer3D = get_node(_trigger_sound_player)


func _on_delay_timer_timeout() -> void:
	# can print message here
	generic.emit()


func _on_generic_signal() -> void:
	if not delay_time < 0.0:
		var delay_timer := Timer.new()
		delay_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		delay_timer.timeout.connect(_on_delay_timer_timeout)
		delay_timer.timeout.connect(delay_timer.queue_free)
		delay_timer.wait_time = clampf(delay_time, 0.05, INF)
		delay_timer.one_shot = true
		add_child(delay_timer, false)
		delay_timer.start()
	# should be possible to delay trigger sound
	trigger_sound_player.play()
