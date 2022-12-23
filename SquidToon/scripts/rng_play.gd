extends AudioStreamPlayer


func _ready():
	randomize()
	randomize()
	randomize()
	var endlength = stream.get_length()
	play(randf_range(0,endlength))
	pass
