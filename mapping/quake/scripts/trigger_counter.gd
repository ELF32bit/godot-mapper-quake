extends Node

signal generic

@export var count: int = 2
@export var message: String = ""

@export_node_path("Timer") var _delay_timer: NodePath
@onready var delay_timer: Timer = get_node_or_null(_delay_timer)


func _on_delay_timer_timeout() -> void:
	generic.emit()


func _on_generic_signal() -> void:
	if count - 1 == 0:
		if is_instance_valid(delay_timer):
			delay_timer.start()
	count = maxi(count - 1, 0)
