extends MeshInstance3D
@onready var draw_viewport = $"../../DrawViewport"


func _ready():
	UvConversion.set_mesh(self)
	(mesh.surface_get_material(0) as ShaderMaterial).set_shader_parameter("view", draw_viewport.get_texture())
