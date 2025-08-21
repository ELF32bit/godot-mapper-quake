extends "trigger_once.gd"

@export var map: String = ""


func _on_trigger_fired() -> void:
	super()


func _on_delay_timer_timeout() -> void:
	var main := get_tree().root.get_child(0)
	if main.has_method("load_map"):
		main.call("load_map", map)


func _on_generic_signal() -> void:
	pass
