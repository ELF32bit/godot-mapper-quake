extends Node

signal generic

@export var message: String = ""
@export var no_messages: bool = false

@export_node_path("Timer") var _delay_timer: NodePath
@onready var delay_timer: Timer = get_node_or_null(_delay_timer)

@export var count: int = 2


func _on_delay_timer_timeout() -> void:
	_message(message)
	generic.emit()


func _on_generic_signal() -> void:
	if count == 0:
		return
	elif count - 1 == 0:
		count = 0
		if not no_messages:
			_message("Sequence completed!")
		if is_instance_valid(delay_timer):
			delay_timer.start()
	else:
		count = maxi(count - 1, 0)
		if not no_messages:
			_message("Only %s more to go..." % count)

@warning_ignore("shadowed_variable")
func _message(message: String) -> void:
	if not message.is_empty():
		print(message)
