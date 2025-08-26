extends StaticBody3D

@export var max_health: int = 2
@onready var quake_health: int = max_health:
	set(value):
		var previous_health := int(quake_health)
		quake_health = clampi(value, 0, max_health)
		if quake_health == 0 and quake_health != previous_health:
			pass


func _explode() -> void:
	pass
