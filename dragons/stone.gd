extends CharacterBody2D

var speed = 800.0
var height = position.y

# Called when the node enters the scene tree for the first time.

const GRAVITY = 600.0

func _ready():
	pass

func _physics_process(delta):
	velocity.y += delta * GRAVITY

	var motion = velocity * delta
	move_and_collide(motion)
	
	if position.y < -20:
		print("jest")
		queue_free()
	elif position.y - height < 0.001:
		print("on ground")
		position.x -= speed * delta

	height = position.y
		
func set_speed(new_speed):
	speed = new_speed
