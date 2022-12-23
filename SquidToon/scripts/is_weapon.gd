extends Node3D

@export var weapon_name: String = "Splattershot"

@onready var weapon_anim = $"../weapon_anim"
@onready var player = $"../../.."

var weapon_model: PackedScene
var weapon_projectile: PackedScene
var weapon_fire_rate: float
var weapon_ink_use: float
var weapon_damage: float
var weapon_accuracy: float
var weapon_aim_animation: String = "automatic_long"
var is_shoot: bool = false

var projectile_position
var instanced_model

var fire_rate_timer

var rng = RandomNumberGenerator.new()

# Do
# The weapon animation playing
# The player animation playing this weapon's type
# The projectile being instanced and sent out, with the projectile having its own script
# depleting ammo and if it is over the amount the weapon's ink use amount, stop firing and give a warning
# if player is in sink state, stop firing, if not continue firing
func shot():
	var projectile_c = weapon_projectile.instantiate() as CharacterBody3D
	get_tree().current_scene.add_child(projectile_c)
	projectile_c.global_transform.origin = projectile_position.global_transform.origin
	projectile_c.global_rotation = projectile_position.global_rotation
	projectile_c.rotate_x(deg_to_rad(rng.randf_range(-weapon_accuracy, weapon_accuracy)))
	projectile_c.rotate_y(deg_to_rad(rng.randf_range(-weapon_accuracy, weapon_accuracy)))
	projectile_c.set_start_velocity()

func _ready():
	fire_rate_timer = Timer.new()
	add_child(fire_rate_timer)
	var weapon_data_current = weapondata.get_weapon_data(weapon_name)
	weapon_fire_rate = weapon_data_current.fire_rate
	weapon_ink_use = weapon_data_current.ink_use
	weapon_damage = weapon_data_current.damage
	weapon_model = load(weapon_data_current.model)
	weapon_projectile = load(weapon_data_current.projectile)
	weapon_aim_animation = weapon_data_current.class_weapon
	weapon_accuracy = weapon_data_current.accuracy
	
	fire_rate_timer.wait_time = (1 / weapon_fire_rate)
	
	instanced_model = weapon_model.instantiate()
	
	add_child(instanced_model)
	
	projectile_position = instanced_model.get_node("shoot")
	fire_rate_timer.connect("timeout",Callable(self,"shot"))



func fire():
	if player.is_on_floor_really == true and is_shoot == false:
		is_shoot = true
		fire_rate_timer.start(0)
		instanced_model.get_node("anim").play("shooting", 0.5)

func release():
	is_shoot = false
	fire_rate_timer.stop()
	instanced_model.get_node("anim").play("to_normal",0.5)

func _input(event):
	if player.is_on_floor_really == false and is_shoot == true:
		is_shoot = false
		fire_rate_timer.stop()
		instanced_model.get_node("anim").play("to_normal",0.5)
