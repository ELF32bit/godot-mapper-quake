extends Area3D

@export var damage: int = 5

@export_node_path("Timer") var _wait_timer: NodePath
@onready var wait_timer: Timer = get_node_or_null(_wait_timer)


func _on_wait_timer_timeout() -> void:
	# area must be monitoring to get overlapping bodies
	if not self.monitoring:
		return
	# iterating over overlapping bodies and hurting them
	for body in self.get_overlapping_bodies():
		_hurt(body, self.damage)

@warning_ignore("shadowed_variable")
func _hurt(body: Node3D, damage: int) -> void:
	if body.has_method("quake_hurt"):
		body.call("quake_hurt", damage)
