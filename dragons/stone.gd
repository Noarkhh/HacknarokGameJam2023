extends RigidBody2D

const OFF_MAP_POSITION = -20

var speed = 800.0
var last_height = 0

const GRAVITY = 600.0

func _ready():
	pass

func _physics_process(delta):
	
	if position.x < OFF_MAP_POSITION:
		queue_free()
		
	if position.y - last_height < 0.001:
		linear_velocity.x = -speed
	
	last_height = position.y

func set_speed(new_speed):
	speed = new_speed
