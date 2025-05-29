#@tool TODO: disable physics process and input for editor
extends Camera3D

enum CameraMode {FIRST_PERSON, THIRD_PERSON}

const HIGHLIGHT_OVERLAY_MATERIAL: Material = preload("RayCastCamera3D.tres")

@export var camera_mode := CameraMode.FIRST_PERSON
@export var select_objects := true
@export var highlight_selected_objects := true
@export var select_distance: float = -1.0
var selected_object: CollisionObject3D = null

@export_flags_3d_physics var collision_mask: int = 0:
	set(value):
		if is_instance_valid(raycast):
			raycast.collision_mask = value
		collision_mask = value

@onready var viewport: Viewport = get_viewport()
@onready var raycast: RayCast3D = $"RayCast3D"


func _ready() -> void:
	collision_mask = collision_mask # updating dependant nodes


func _input(event: InputEvent) -> void: # TODO: rework
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_instance_valid(selected_object):
				if Input.is_key_pressed(KEY_CTRL):
					if "health" in selected_object:
						print(selected_object.health)
						selected_object.health -= 1
					elif selected_object.has_method("apply_central_impulse"):
						selected_object.apply_central_impulse(-global_transform.basis.z)
						#selected_object.queue_free()

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not select_objects or (camera_mode == CameraMode.THIRD_PERSON and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE):
		if is_instance_valid(selected_object):
			unhighlight_object(selected_object)
			selected_object = null
		return
	if not highlight_selected_objects and is_instance_valid(selected_object):
		unhighlight_object(selected_object)

	var object: CollisionObject3D = null
	if camera_mode == CameraMode.FIRST_PERSON:
		object = select_object(select_distance)
	else:
		object = select_object_with_mouse(select_distance)

	if object != selected_object:
		if highlight_selected_objects:
			if is_instance_valid(selected_object):
				unhighlight_object(selected_object)
			if is_instance_valid(object):
				highlight_object(object)
		selected_object = object


func select_object(distance: float = -1.0) -> CollisionObject3D:
	var forward := -global_transform.basis.z.normalized()
	distance = (far if select_distance < 0.0 else select_distance) if distance < 0.0 else distance
	var target_position := global_position + forward * distance
	raycast.target_position = raycast.to_local(target_position)
	raycast.force_raycast_update()
	raycast.target_position = Vector3.ZERO
	if raycast.is_colliding():
		return raycast.get_collider()
	return null


func select_object_with_mouse(distance: float = -1.0) -> CollisionObject3D:
	var mouse_position := viewport.get_mouse_position()
	distance = (far if select_distance < 0.0 else select_distance) if distance < 0.0 else distance
	var target_position := global_position + project_ray_normal(mouse_position) * distance
	raycast.target_position = raycast.to_local(target_position)
	raycast.force_raycast_update()
	raycast.target_position = Vector3.ZERO
	if raycast.is_colliding():
		return raycast.get_collider()
	return null


func unhighlight_object(object: CollisionObject3D) -> void:
	for child in object.get_children():
		if child is GeometryInstance3D:
			if child.material_overlay == HIGHLIGHT_OVERLAY_MATERIAL:
				child.material_overlay = null


func highlight_object(object: CollisionObject3D) -> void:
	for child in object.get_children():
		if child is GeometryInstance3D:
			if not child.material_overlay:
				child.material_overlay = HIGHLIGHT_OVERLAY_MATERIAL
