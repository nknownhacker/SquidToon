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
export(float) var aim_distance: float = 5

onready var gimba_h = $GimbaH
onready var gimba_v = $GimbaH/GimbaV
onready var clipped_camera = $GimbaH/GimbaV/ClippedCamera

var _rot_h: float = 0
var _rot_v: float = 0
var is_capturing = true
var _distance: float = 8

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
	
	if is_capturing:
		if Input.is_action_pressed("aim"):
			_distance = aim_distance
		else:
			_distance = max_distance
			

func _physics_process(delta):
	gimba_h.rotation_degrees.y = lerp(gimba_h.rotation_degrees.y, _rot_h, rotate_speed * delta)
	gimba_v.rotation_degrees.x = lerp(gimba_v.rotation_degrees.x, _rot_v, rotate_speed * delta)
	
	clipped_camera.transform.origin.z = lerp(clipped_camera.transform.origin.z, _distance, zoom_speed * delta)
