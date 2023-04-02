extends Node2D

@export var speed = 20.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Sprite2D.position += Vector2.LEFT * speed * delta
	$Sprite2D2.position += Vector2.LEFT * speed * delta
	
#	print($Sprite2D.position)
	
	if ($Sprite2D.position.x <= -1280):
		$Sprite2D.position.x = $Sprite2D2.position.x + 1280 * 2
	elif ($Sprite2D2.position.x <= -1280):
		$Sprite2D2.position.x = $Sprite2D.position.x + 1280 * 2
		
