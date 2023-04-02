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
	dragons[0].activate(125)

func next_segment() -> void:
	var new_obstacles_segment = segments_scenes[randi() % segments_scenes.size()].instantiate()
	new_obstacles_segment.init(segment_speed, 1920)
	get_parent().add_child(new_obstacles_segment)
	get_parent().move_child(new_obstacles_segment, 2)
	dragons[0].start_attack()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
