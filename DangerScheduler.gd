extends Timer

var segments_scenes = [preload("res://segment_barrel_stack.tscn"), preload("res://segment_market.tscn")]

var segment_queue = []

var segment_speed = 500.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_autostart(true)
	wait_time = 1270.0 / segment_speed
	timeout.connect(on_timer_timeout)
	

func on_timer_timeout() -> void:
	var new_obstacles_segment = segments_scenes[randi() % segments_scenes.size()].instantiate()
	new_obstacles_segment.set_speed(segment_speed)
	get_parent().add_child(new_obstacles_segment)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
