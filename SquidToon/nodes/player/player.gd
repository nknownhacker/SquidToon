extends CharacterBody3D


@export var move_speed: float = 10
@export var turn_speed: float = 5
@export var jump_force: float = 15
@export var acceleration: float = 10
@export var gravity: float = .90
@export var max_terminal_velocity: float = 20
@export var max_slope_angle: float = 50
@export var cam_follow_speed: float = 8

@export var skin_color: Color = Color(1,1,1,1)

@onready var _skin = $skin
@onready var control_camera = $camroot/control_camera
@onready var gimbah = $camroot/control_camera/GimbaH
@onready var gimbav = $camroot/control_camera/GimbaH/GimbaV
@onready var weapon = $skin/hold/weapon
@onready var hold = $skin/hold
@onready var weapon_anim = $skin/hold/weapon_anim

var _move_dir: Vector2 = Vector2.ZERO
var _is_jumping: bool = false
var _move_rot: float = 0
var aim_speed: float = 6.5

var _velocity: Vector3 = Vector3.ZERO
var _y_velocity: float = 0
var _rotation: float = 0

var bool_check_t: int = 0
var is_on_floor_really: bool = false
var player_color: Color = Color(1,1,1,1)

func _ready():
	var skin_material = StandardMaterial3D.new()
	skin_material.albedo_color = skin_color
	for i in range(_skin.get_child_count()):
		if _skin.get_child(i).get_class() == "MeshInstance3D":
			_skin.get_child(i).mesh.surface_set_material(0,skin_material)
			pass

func _process(delta):
	var dx := Input.get_action_strength("right") - Input.get_action_strength("left")
	var dy := Input.get_action_strength("forward") - Input.get_action_strength("backward")
	_move_dir = Vector2(dx, -dy).normalized()
	_is_jumping = Input.is_action_pressed("jump")
	
	if Input.is_action_just_pressed("aim"):
		weapon_anim.play(weapon.weapon_aim_animation)
	elif Input.is_action_just_released("aim"):
		weapon_anim.play_backwards(weapon.weapon_aim_animation)
	
	if Input.is_action_pressed("fire"):
		weapon.fire()
	elif Input.is_action_just_released("fire"):
		weapon.release()


func _physics_process(delta):
	var direction = Vector3(_move_dir.x, 0, _move_dir.y)
	_move_rot = lerp(_move_rot, deg_to_rad(control_camera._rot_h), cam_follow_speed * delta)
	direction = direction.rotated(Vector3.UP, _move_rot)
	
	if Input.is_action_pressed("aim") and is_on_floor_really:
		_velocity = _velocity.lerp(direction * aim_speed, acceleration*delta)
	else:
		_velocity = _velocity.lerp(direction * move_speed, acceleration*delta)
	
	if is_on_floor():
		_y_velocity = -0.01
	else:
		_y_velocity = clamp(_y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)
	
	if is_on_floor() && _is_jumping:
		_is_jumping = false
		_y_velocity = jump_force
	
	# player bhopping makes it twitch checked changes, so I have this as a stopper of twitches from that result
	if is_on_floor() and bool_check_t < 2:
		bool_check_t += 1
	elif is_on_floor() and bool_check_t >= 2:
		is_on_floor_really = true
	else:
		bool_check_t = 0
		is_on_floor_really = false
	
	if Input.is_action_pressed("aim") and is_on_floor_really:
		_rotation = lerp_angle(_rotation, gimbah.rotation.y, turn_speed * 3 * delta)
		_skin.rotation.y = _rotation
		hold.rotation.z = gimbah.rotation.z
		hold.rotation.x = gimbav.rotation.x
	elif _move_dir != Vector2.ZERO:
		_rotation = lerp_angle(_rotation, atan2(-direction.x,-direction.z), turn_speed * delta)
		_skin.rotation.y = _rotation
	
	_velocity.y = _y_velocity
	set_velocity(_velocity)
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(false)
	set_max_slides(4)
	set_floor_max_angle(deg_to_rad(max_slope_angle))
	move_and_slide()
	_velocity = velocity
	
