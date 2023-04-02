extends Node2D

var speed = 800.0

# Called when the node enters the scene tree for the first time.
func _ready():
#	position = Vector2(1920, 720 - 160)
	pass

func init(new_speed: float, position_x: float) -> void:
	speed = new_speed
	position = Vector2(position_x, 720 - 160)
	
func set_speed(new_speed: float) -> void:
	speed = new_speed
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += Vector2.LEFT * speed * delta
