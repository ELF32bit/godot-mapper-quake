@tool
extends "func_wall.gd"

signal generic

@export var max_health: int = 1
@onready var health: int = max_health:
	set(value):
		var previous_health := health
		health = clampi(value, 0, max_health)
		if health != previous_health:
			# health has changed here
			if health == 0:
				generic.emit()
