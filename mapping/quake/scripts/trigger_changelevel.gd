extends "trigger_once.gd"

@export var map: String = ""


func _on_trigger_fired() -> void:
	super()


func _on_delay_timer_timeout() -> void:
	pass # change map after the delay


func _on_generic_signal() -> void:
	pass
