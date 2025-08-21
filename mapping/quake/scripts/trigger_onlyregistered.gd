extends "trigger_once.gd"

@export var is_registered: bool = true


func _on_trigger_fired() -> void:
	if not is_registered:
		return
	super()
