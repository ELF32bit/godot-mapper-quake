extends "classes/crushing.gd"

signal generic # only used for linked doors and not the main door
signal activated # emitted when health ended or generic signal received by linked door

@export var message: String = ""

@export var max_health: int = 0
@onready var quake_health: int = max_health:
	set(value):
		var previous_health := int(quake_health)
		quake_health = clampi(value, 0, max_health)
		if quake_health == 0 and quake_health != previous_health:
			generic.emit()


func _on_opening_signal() -> void:
	generic.emit()
	quake_health = 0


func _on_closing_signal() -> void:
	quake_health = max_health


func _on_generic_signal() -> void:
	activated.emit() # rerouting generic signal from linked door to the main door

@warning_ignore("shadowed_variable")
func _message(message: String) -> void:
	if not message.is_empty():
		print(message)
