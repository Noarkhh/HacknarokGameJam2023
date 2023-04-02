extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.play("start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y = get_parent().get_node("laser_dragon").position.y
	
#func synced_with_dragon():


func start_animation_finished():
	$Sprite2D.play("cycle")
	

func _on_player_hit(area):
	print("area_hit")
	if area == get_parent().get_node("Player"):
		area.player_hit(1.0)
		
