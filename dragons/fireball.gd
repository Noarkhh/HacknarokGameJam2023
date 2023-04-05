extends Area2D

var velocity = Vector2(0, -200)
# Called when the node enters the scene tree for the first time.
func _ready():
	var lifetime_timer = Timer.new()
	lifetime_timer.set_wait_time(1.2)
	lifetime_timer.set_one_shot(true)
	lifetime_timer.timeout.connect(kill)
	add_child(lifetime_timer)
	lifetime_timer.start()
	
func init(new_speed: float) -> void:
	velocity.x = new_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += gravity * delta
	
	position += velocity * delta
	
func kill():
	
	queue_free()


func _on_player_hit(area):
#	print("area_hit")
	if area == get_parent().get_node("Player"):
		area.player_hit(1.0)
