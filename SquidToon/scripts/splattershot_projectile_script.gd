extends CharacterBody3D

@export var Colored: Color = Color.RED
@export var speed = 5.0

var _veloc = Vector3(0,0,0)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var draw_viewport = get_tree().current_scene.get_node("DrawViewport")
@onready var mesh = $mesh

func set_start_velocity():
	_veloc = (global_transform.basis * Vector3.FORWARD).normalized() * speed
	_veloc.z = _veloc.z * 5
	_veloc.y = _veloc.y * 5
	_veloc.x = _veloc.x * 5

func _physics_process(delta):
	_veloc.y -= gravity * delta
	look_at((global_transform.origin + _veloc), Vector3(0,0,5))
	
	set_velocity(_veloc)
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		for i in range(0, get_slide_collision_count()):
			var col = get_slide_collision(i)
			var uv = UvConversion.get_uv_coords(col.get_position(), col.get_normal(), true)
			if uv:
				draw_viewport.paint(uv, Colored)
		queue_free()

func _on_hit_body_entered(body):
	pass
	#if body.is_in_group("humanoid"):
	#	queue_free()
	#else:
	#	queue_free()
