extends Spatial

class_name control_camera

export(float) var min_pitch: float = -90
export(float) var max_pitch: float = 75
export(float) var rotate_speed: float = 10
export(float) var sensitivity: float = .1
export(float) var zoom_speed: float = 10
export(float) var zoom_step: float = .5
export(float) var min_distance: float = 3
export(float) var max_distance: float = 8
export(float) var aim_distance: float = 4

onready var gimba_h = $GimbaH
onready var gimba_v = $GimbaH/GimbaV
onready var clipped_camera = $GimbaH/GimbaV/ClippedCamera
onready var player = get_parent().get_parent()

var _rot_h: float = 0
var _rot_v: float = 0
var is_capturing = true
var _distance: float = 8
var _distancex: float = 2

var bool_check_t: int = 0
var is_on_floor_really : bool = false

func _ready():
	yield(get_parent(), "ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		is_capturing = !is_capturing
		
		if is_capturing:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if is_capturing and event is InputEventMouseMotion:
		_rot_h -= event.relative.x * sensitivity
		_rot_v -= event.relative.y * sensitivity
	
	_rot_v = clamp(_rot_v, min_pitch, max_pitch)
			

func _physics_process(delta):
	# When player aims and doesn't move the mouse, this value wouldn't change, so I set it in physics process instead of input
	# so it would change when the player aims
	if is_capturing:
		# Checking if holding right mouse and is on the floor
		if Input.is_action_pressed("aim") and is_on_floor_really:
			_distance = aim_distance
			_distancex = 1
		else:
			_distance = max_distance
			_distancex = 0
	if player.is_on_floor() and bool_check_t < 2:
		bool_check_t += 1
	elif player.is_on_floor() and bool_check_t >= 2:
		is_on_floor_really = true
	else:
		bool_check_t = 0
		is_on_floor_really = false
	
	gimba_h.rotation_degrees.y = lerp(gimba_h.rotation_degrees.y, _rot_h, rotate_speed * delta)
	gimba_v.rotation_degrees.x = lerp(gimba_v.rotation_degrees.x, _rot_v, rotate_speed * delta)
	
	clipped_camera.transform.origin.z = lerp(clipped_camera.transform.origin.z, _distance, zoom_speed * delta)
	clipped_camera.transform.origin.x = lerp(clipped_camera.transform.origin.x, _distancex, zoom_speed * delta)
