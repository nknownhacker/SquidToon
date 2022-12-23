extends Node

var red_score := 0
var blue_score := 0

var thread: Thread
var semaphore: Semaphore
var mutex: Mutex
var exit := false

@onready var draw_viewport = $"../DrawViewport"
@onready var label = $"../label"

var paint_texture: ViewportTexture

func _ready():
	paint_texture = draw_viewport.get_texture()
	
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	thread = Thread.new()
	thread.start(_thread_calculate_score)
	
func recalculate_score():
	await RenderingServer.frame_post_draw
	semaphore.post()
	label.text = "red score: " + str(red_score)
	
func _thread_calculate_score():
	while true:
		semaphore.wait()
		
		mutex.lock()
		var should_exit := exit
		mutex.unlock()
		
		if should_exit:
			break
		
		mutex.lock()
		var image := paint_texture.get_image()
		mutex.unlock()
		
		var size = image.get_size()
		var blue_pixels := 0
		var red_pixels := 0
		
		for y in range(0, size.y):
			for x in range(0, size.x):
				var pixel = image.get_pixel(x, y)
				if pixel.r >= 0.5:
					red_pixels += 1
				if pixel.b >= 0.5:
					blue_pixels += 1
					
		mutex.lock()
		blue_score = floor(blue_pixels/1000)
		red_score = floor(red_pixels/1000)
		mutex.unlock()

func _exit_tree():
	mutex.lock()
	exit = true
	mutex.unlock()
	
	semaphore.post()
	thread.wait_to_finish()
