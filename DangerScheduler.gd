extends Timer

var starting_segment_scene = preload("res://obstacles/segments/segment_obstacles.tscn")
var segments_scenes = [
	preload("res://obstacles/segments/segment_barrel_stack.tscn"),
	preload("res://obstacles/segments/segment_crate_stack.tscn"),
	preload("res://obstacles/segments/segment_market.tscn"),
	preload("res://obstacles/segments/segment_scaffolding_triangle.tscn")
	]
	
var dragons = []

var segment_queue = []

var base_speed = 500.0
var n = 7

var speed_multiplier = log(n) / log(7)

var segment_speed = speed_multiplier * base_speed

var curr_dragon = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_autostart(true)
	wait_time = 1275.0 / segment_speed
	timeout.connect(next_segment)
	
	var starting_segment = starting_segment_scene.instantiate()
	starting_segment.init(segment_speed, 640)
	get_parent().add_child.call_deferred(starting_segment)
	get_parent().move_child.call_deferred(starting_segment, 2)
	segment_queue.push_back(starting_segment)

	starting_segment = starting_segment_scene.instantiate()
	starting_segment.init(segment_speed, 1920)
	get_parent().add_child.call_deferred(starting_segment)
	get_parent().move_child.call_deferred(starting_segment, 2)
	segment_queue.push_back(starting_segment)
		
	
	get_parent().get_node("WallLayer").base_speed = base_speed
	

	dragons.append(get_parent().get_node("laser_dragon"))
	dragons.append(get_parent().get_node("fireball_dragon"))
	dragons.append(get_parent().get_node("stone_dragon"))
	
	dragons[curr_dragon].activate(125.0)

func next_segment() -> void:
	var new_obstacles_segment = segments_scenes[randi() % segments_scenes.size()].instantiate()
	new_obstacles_segment.init(segment_speed, 1920)
	get_parent().add_child(new_obstacles_segment)
	get_parent().move_child(new_obstacles_segment, 2)
	segment_queue.push_back(new_obstacles_segment)
	
	
	n += 1
	speed_multiplier = log(n) / log(7)
	
	segment_queue.pop_front().queue_free()
	
	segment_speed = base_speed * speed_multiplier
	
	segment_queue[0].set_speed(segment_speed)
	segment_queue[1].set_speed(segment_speed)
	
	get_parent().get_node("Background").multiply_base_speed(speed_multiplier)
	get_parent().get_node("WallLayer").multiply_base_speed(speed_multiplier)
	
	wait_time = 1275.0 / segment_speed
	
	if (randi() % 10 == 0):
		dragons[curr_dragon].leave()
		curr_dragon = (curr_dragon + 1) % 3
		dragons[curr_dragon].activate(125.0 * speed_multiplier)
		
	if (randi() % 3 == 0):
		dragons[curr_dragon].start_attack()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_parent().get_node("UI/ScoreLabel").update_score(delta * segment_speed)
