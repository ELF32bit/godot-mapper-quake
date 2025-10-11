extends StaticBody3D

@export var max_health: int = 20
@onready var quake_health: int = max_health:
	set(value):
		var previous_health := int(quake_health)
		quake_health = clampi(value, 0, max_health)
		if quake_health == 0 and quake_health != previous_health:
			_explode()

@export var damage: int = 80

@export_node_path("Area3D") var _area: NodePath
@onready var area: Area3D = get_node(_area)


func _explode() -> void:
	for body in area.get_overlapping_bodies():
		if body.has_method("_quake_explode"):
			body.call("_quake_explode", damage)
	area.get_parent().queue_free()
