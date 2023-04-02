extends Node2D

@export var base_speed = 20.0
var speed
# Called when the node enters the scene tree for the first time.
func _ready():
	speed = base_speed

func multiply_base_speed(multiplier: float) -> void:
	speed = base_speed * multiplier
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Sprite2D.position += Vector2.LEFT * speed * delta
	$Sprite2D2.position += Vector2.LEFT * speed * delta
	

	if ($Sprite2D.position.x <= -1280):
		$Sprite2D.position.x = $Sprite2D2.position.x + 1280 * 2 - 1
	elif ($Sprite2D2.position.x <= -1280):
		$Sprite2D2.position.x = $Sprite2D.position.x + 1280 * 2 - 1
		
