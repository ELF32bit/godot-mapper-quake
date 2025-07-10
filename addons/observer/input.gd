extends Node

const MOUSE_SENSITIVITY: float = 0.276
const JOYPAD_SENSITIVITY: float = 5.76

@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.5
@export_range(0.0, 1.0) var joypad_sensitivity: float = 0.5
@export_range(0.0, 1.0) var joy_axis_left_deadzone := 0.05
@export_range(0.0, 1.0) var joy_axis_right_deadzone := 0.05

var scroll_number: int = 0
var mouse_motion := Vector2.ZERO
var joy_axis_right := Vector2.ZERO
var move_vector := Vector2.ZERO

var is_up_pressed := false
var is_down_pressed := false
var is_local_up_pressed := false
var is_local_down_pressed := false
var is_teleport_pressed := false
var is_fast_pressed := false
var is_slow_pressed := false
var is_noclip_pressed := false
var is_modifier_pressed := false
var is_orbit_pressed := false
var is_reset_pressed := false


func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			mouse_motion += event.relative
			return

	if event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_RIGHT_X:
				joy_axis_right.x = event.axis_value
			JOY_AXIS_RIGHT_Y:
				joy_axis_right.y = event.axis_value
		if joy_axis_right.length() < joy_axis_right_deadzone:
			joy_axis_right = Vector2.ZERO
		return

	if event is InputEventMouseButton:
		var scroll: int = 0
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				scroll_number += 1
			MOUSE_BUTTON_WHEEL_DOWN:
				scroll_number -= 1
		return

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	move_vector = Vector2.ZERO
	is_up_pressed = false
	is_down_pressed = false
	is_local_up_pressed = false
	is_local_down_pressed = false
	is_teleport_pressed = false
	is_fast_pressed = false
	is_slow_pressed = false
	is_noclip_pressed = false
	is_modifier_pressed = false
	is_orbit_pressed = false
	is_reset_pressed = false

	var joypad_index := Input.get_connected_joypads().size() - 1
	if joypad_index >= 0:
		move_vector.x = Input.get_joy_axis(joypad_index, JOY_AXIS_LEFT_X)
		move_vector.y = -Input.get_joy_axis(joypad_index, JOY_AXIS_LEFT_Y)
		if move_vector.length() < joy_axis_left_deadzone:
			move_vector = Vector2.ZERO

		is_up_pressed = Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_RIGHT_SHOULDER)
		is_down_pressed = Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_LEFT_SHOULDER)
		is_local_up_pressed = bool(Input.get_joy_axis(joypad_index, JOY_AXIS_TRIGGER_RIGHT))
		is_local_down_pressed = bool(Input.get_joy_axis(joypad_index, JOY_AXIS_TRIGGER_LEFT))
		is_teleport_pressed = Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_X)
		is_fast_pressed = Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_A)
		is_slow_pressed = Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_B)
		is_noclip_pressed = Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_Y)
		is_orbit_pressed = Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_RIGHT_STICK)
		is_reset_pressed = Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_LEFT_STICK)
		if is_reset_pressed:
			is_modifier_pressed = true

		if Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_DPAD_UP):
			scroll_number += 1
		if Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_DPAD_DOWN):
			scroll_number -= 1
		if Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_DPAD_RIGHT):
			scroll_number += 1
			is_modifier_pressed = true
		if Input.is_joy_button_pressed(joypad_index, JOY_BUTTON_DPAD_LEFT):
			scroll_number -= 1
			is_modifier_pressed = true

	if Input.is_key_pressed(KEY_W):
		move_vector.y = 1.0
	if Input.is_key_pressed(KEY_A):
		move_vector.x = -1.0
	if Input.is_key_pressed(KEY_S):
		move_vector.y = -1.0
	if Input.is_key_pressed(KEY_D):
		move_vector.x = 1.0

	if Input.is_key_pressed(KEY_E):
		is_up_pressed = true
	if Input.is_key_pressed(KEY_Q):
		is_down_pressed = true
	if Input.is_key_pressed(KEY_R):
		is_local_up_pressed = true
	if Input.is_key_pressed(KEY_F):
		is_local_down_pressed = true
	if Input.is_key_pressed(KEY_SPACE):
		is_teleport_pressed = true
	if Input.is_key_pressed(KEY_SHIFT):
		is_fast_pressed = true
	if Input.is_key_pressed(KEY_ALT):
		is_slow_pressed = true
	if Input.is_key_pressed(KEY_TAB):
		is_noclip_pressed = true
	if Input.is_key_pressed(KEY_CTRL):
		is_modifier_pressed = true
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_orbit_pressed = true
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		is_reset_pressed = true

	if is_orbit_pressed or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func get_free_look() -> Vector2:
	var free_look := Vector2.ZERO
	free_look -= mouse_motion * lerpf(0.0, MOUSE_SENSITIVITY, mouse_sensitivity)
	free_look -= joy_axis_right * lerpf(0.0, JOYPAD_SENSITIVITY, joypad_sensitivity)
	mouse_motion = Vector2.ZERO # consuming accumulated mouse motion
	return free_look


func get_scroll_number() -> int:
	var accumulated_scroll_number := int(scroll_number)
	scroll_number = 0 # consuming accumulated scroll number
	return accumulated_scroll_number
