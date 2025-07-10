extends AudioStreamPlayer3D

@export var noises: Array[AudioStream] = []


func _ready() -> void:
	_on_timer_timeout()


func _on_timer_timeout() -> void:
	if noises.size() > 0:
		stream = noises[randi() % noises.size()]
		playing = true
