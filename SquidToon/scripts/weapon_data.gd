extends Node

var weapon_data = {
	"Splattershot": {
		"aim_speed": 6.5,
		"fire_rate": 10,
		"ink_use": 1,
		"damage": 10,
		"accuracy": 2,
		"projectile": "res://nodes/splattershot_projectile.tscn",
		"model": "res://assets/models/splattershot.tscn",
		"class_weapon": "automatic_long",
		}
	}

func _ready():
	pass

func get_weapon_data(weapon_name):
	return weapon_data[weapon_name]
