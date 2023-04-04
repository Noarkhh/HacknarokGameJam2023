extends StaticBody2D

var speed = 500.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_speed(new_speed: float) -> void:
	speed = new_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	position += Vector2.LEFT * speed * delta
	pass
