extends Timer

var starting_segment_scene = preload("res://segment_obstacles.tscn")
var segments_scenes = [
	preload("res://segment_barrel_stack.tscn"), 
	preload("res://segment_market.tscn")
	]
	
var dragons = []

var segment_queue = []

var segment_speed = 500.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_autostart(true)
	wait_time = 1275.0 / segment_speed
	timeout.connect(next_segment)
	
	var starting_segment = starting_segment_scene.instantiate()
	starting_segment.init(segment_speed, 640)
	get_parent().add_child.call_deferred(starting_segment)
	get_parent().move_child.call_deferred(starting_segment, 2)

	starting_segment = starting_segment_scene.instantiate()
	starting_segment.init(segment_speed, 1920)
	get_parent().add_child.call_deferred(starting_segment)
	get_parent().move_child.call_deferred(starting_segment, 2)
	
	dragons.append(get_parent().get_node("laser_dragon"))
	dragons[0].activate(125.0)
	dragons.append(get_parent().get_node("fireball_dragon"))
	dragons[1].activate(125.0)
	dragons.append(get_parent().get_node("stone_dragon"))
	dragons[2].activate(125.0)

func next_segment() -> void:
	var new_obstacles_segment = segments_scenes[randi() % segments_scenes.size()].instantiate()
	new_obstacles_segment.init(segment_speed, 1920)
	get_parent().add_child(new_obstacles_segment)
	get_parent().move_child(new_obstacles_segment, 2)
	dragons[0].start_attack()
	dragons[1].start_attack()
	dragons[2].start_attack()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
