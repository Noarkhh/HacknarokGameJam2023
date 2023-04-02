extends CharacterBody2D

enum State {
	DEFAULT,
	ATTACK
}

@export var move_speed = 125
@export var moving = false
@export var current_state = State.DEFAULT

var destination_position
var attack_timer = null
var attack_started = false
var attack_finished = false
var track_player = false
var active = false
var stones_to_shot = 3

func _ready():
	position = $InitialPosition.position
	activate(move_speed)

func activate(speed):
	destination_position = $DefaultPosition.position
	moving = true
	active = true
	move_speed = speed + 75

func _physics_process(delta):
	go_to_destination(delta)
	if moving == false and attack_finished and attack_started:
		attack_started = false
		attack_finished = false
	if moving == false and not attack_started:
		start_attack()
	if track_player:
		destination_position.x = get_parent().get_node("Player").position.x
		moving = true
	move_and_slide()

func go_to_destination(delta):
	if moving:
		var direction = destination_position - position
		var distance = direction.length()
		var movement = direction.normalized() * min(distance, move_speed * delta)
		position += movement
	if position == destination_position:
		moving = false

func start_attack():
	if moving or attack_started:
		print("Cannot attack: dragon is busy")
		return null

	attack_started = true
	moving = true
	stones_to_shot = 3
	destination_position = $StoneAttackPosition.position
	attack_timer = Timer.new()
	attack_timer.set_wait_time(calculate_movement_time())
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(stone_attack)
	add_child(attack_timer)
	attack_timer.start()


func stone_attack():
	attack_timer = Timer.new()
	if stones_to_shot == 3:
		track_player = true
		stones_to_shot -= 1
		current_state = State.ATTACK
		attack_timer.set_wait_time(400 / move_speed)
		attack_timer.timeout.connect(stone_attack)
		
	elif stones_to_shot >= 0:
		stones_to_shot -= 1
		print("attack")
		current_state = State.ATTACK
		attack_timer = Timer.new()
		attack_timer.set_wait_time(400 / move_speed)
		attack_timer.timeout.connect(stone_attack)
		
	else:
		attack_timer = Timer.new()
		attack_timer.set_wait_time(100 / move_speed)
		attack_timer.timeout.connect(finish_attack)
		
		
	attack_timer.set_one_shot(true)
	add_child(attack_timer)
	attack_timer.start()

func finish_attack():
	track_player = false
	destination_position = $DefaultPosition.position
	moving = true
	attack_finished = true
	current_state = State.DEFAULT
	
func calculate_movement_time():
	var direction = destination_position - position
	var distance = direction.length()
	return distance / move_speed

func leave():
	move_speed = 800
	destination_position = $ExitPosition.position
	moving = true

######################################################33

func set_move_speed(new_move_speed):
	move_speed = new_move_speed
	
func get_move_speed():
	return move_speed


