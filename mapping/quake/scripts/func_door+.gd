extends "classes/PhysicsCrushingBody3D.gd"

signal generic # only used for linked doors and not the main door
signal activated # emitted when health ended or generic signal received by linked door

@export var max_health: int = 0
@onready var health: int = max_health:
	set(value):
		var previous_health := health
		health = clampi(value, 0, max_health)
		if health != previous_health:
			# health has changed here
			if health == 0:
				activated.emit()
@export var message: String = ""


func _on_opening_signal() -> void:
	generic.emit()
	health = 0


func _on_closing_signal() -> void:
	health = max_health


func _on_generic_signal() -> void:
	activated.emit() # rerouting generic signal from linked door to the main door
