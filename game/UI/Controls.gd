extends CanvasLayer

onready var camguide_y = get_parent().get_node("char1_controller/camguide_y")
onready var camguide_x = get_parent().get_node("char1_controller/camguide_y/camguide_x")
onready var joystick_handle = $Control/bg/inner

signal direction_vector

var joystick_active = false
var direction = Vector3.ZERO
var joystick_vector = Vector2.ZERO
var joystick_vector_normalized = Vector2.ZERO
var joystick_center
var joystick_index = -1
var attack_index = -1
var s1_index = -1
var s2_index = -1
var dodge_index = -1
var camera_index = -1
var camera_input = Vector2.ZERO
var rotation_velocity_x = 0
var rotation_velocity_y = 0

func _ready():
	joystick_center = joystick_handle.global_position

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if Input.is_action_just_pressed("joystick_action"):
				joystick_index = event.index
				joystick_active = true
			elif Input.is_action_just_pressed("attack_action"):
				attack_index = event.index
			elif Input.is_action_just_pressed("s1_action"):
				s1_index = event.index
			elif Input.is_action_just_pressed("s2_action"):
				s2_index = event.index
			elif Input.is_action_just_pressed("dodge_action"):
				dodge_index = event.index
			else:
				camera_index = event.index
		else:
			if Input.is_action_just_released("joystick_action"):
				joystick_index = -1
				joystick_handle.global_position = joystick_center
			elif Input.is_action_just_released("attack_action"):
				attack_index = -1
			elif Input.is_action_just_released("s1_action"):
				s1_index = -1
			elif Input.is_action_just_released("s2_action"):
				s2_index = -1
			elif Input.is_action_just_released("dodge_action"):
				dodge_index = -1
			else:
				camera_index = -1
				
	if event is InputEventScreenDrag:
		if event.index == joystick_index:
			joystick_vector = event.position - joystick_center
			joystick_vector_normalized = joystick_vector.normalized()
			joystick_handle.global_position = joystick_center + joystick_vector.clamped(80)
		if event.index == camera_index:
			camera_input = event.relative

func _process(delta):
	$Label.text = str(Engine.get_frames_per_second())
	if joystick_active:
		direction = -(camguide_y.transform.basis.z*joystick_vector_normalized.y + camguide_y.transform.basis.x * joystick_vector_normalized.x)
		emit_signal('direction_vector', direction)
		print(direction)
	else:
		emit_signal('direction_vector', Vector3.ZERO)
	rotation_velocity_x = lerp(rotation_velocity_x, camera_input.x * 0.4, delta * 10)
	rotation_velocity_y = lerp(rotation_velocity_y, camera_input.y * 0.15, delta * 10)
	camguide_x.rotate_x(deg2rad(rotation_velocity_y))
	camguide_y.rotate_y(-deg2rad(rotation_velocity_x))
	camguide_x.rotation.x = clamp(camguide_x.rotation.x, -0.5, 0.5)
	camera_input = Vector2.ZERO
