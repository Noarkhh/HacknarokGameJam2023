extends Label

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func update_score(score_to_add: float) -> void:
	score += score_to_add / 20
	text = "Score: " + str(int(score))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
