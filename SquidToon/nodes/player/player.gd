extends KinematicBody

export(float) var move_speed: float = 10
export(float) var turn_speed: float = 5
export(float) var jump_force: float = .01
export(float) var acceleration: float = 10
export(float) var gravity: float = .90
export(float) var max_terminal_velocity: float = 20
export(float) var max_slope_angle: float = 50
export(float) var cam_follow_speed: float = 8

onready var _skin = $skin
onready var control_camera = $camroot/control_camera
onready var gimbah = $camroot/control_camera/GimbaH
onready var gimbav = $camroot/control_camera/GimbaH/GimbaV

var _move_dir: Vector2 = Vector2.ZERO
var _is_jumping: bool = false
var _move_rot: float = 0

var _velocity: Vector3 = Vector3.ZERO
var _y_velocity: float = 0
var _rotation: float = 0

func _process(delta):
	var dx := Input.get_action_strength("right") - Input.get_action_strength("left")
	var dy := Input.get_action_strength("forward") - Input.get_action_strength("backward")
	
	_move_dir = Vector2(dx, -dy).normalized()
	_is_jumping = Input.is_action_pressed("jump")


func _physics_process(delta):
	var direction = Vector3(_move_dir.x, 0, _move_dir.y)
	
	_move_rot = lerp(_move_rot, deg2rad(control_camera._rot_h), cam_follow_speed * delta)
	direction = direction.rotated(Vector3.UP, _move_rot)
	
	_velocity = _velocity.linear_interpolate(direction * move_speed, acceleration*delta)
	
	if is_on_floor():
		_y_velocity = -0.01
	else:
		_y_velocity = clamp(_y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)
	
	if is_on_floor() && _is_jumping:
		_is_jumping = false
		_y_velocity = jump_force
	
	
	if Input.is_action_pressed("aim"):
		_rotation = lerp_angle(_rotation, deg2rad(gimbah.rotation_degrees.y), turn_speed * delta)
		_skin.rotation.y = _rotation
	elif _move_dir != Vector2.ZERO:
		_rotation = lerp_angle(_rotation, atan2(-direction.x,-direction.z), turn_speed * delta)
		_skin.rotation.y = _rotation
	_velocity.y = _y_velocity
	_velocity = move_and_slide(_velocity, Vector3.UP, false, 4, deg2rad(max_slope_angle))
	
