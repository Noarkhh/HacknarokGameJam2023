extends CharacterBody2D

enum State {
	DEFAULT,
	ATTACK
}

@export var move_speed = 125.0
@export var moving = false
@export var current_state = State.DEFAULT
@export var laser_attack_time = 2.0

const LASER_UPPER_BOUNDRY = 300
const LASER_LOWER_BOUNDRY = 500

var destination_position
var attack_timer = null
var attack_started = false
var attack_finished = false
var rng = RandomNumberGenerator.new()
var active = false

var track_player = false

func _ready():
	rng.randomize()
	position = $InitialPosition.position
	activate(move_speed)
	
func activate(speed: int):
	destination_position = $DefaultPosition.position
	moving = true
	active = true
	move_speed = speed
	
func _physics_process(delta):
	if not moving and attack_finished and attack_started:
		attack_started = false
		attack_finished = false
#	if not moving and active:
#		start_attack()
	if not moving and not active:
		position = $InitialPosition.position
	if track_player and not moving:
		destination_position.y = get_parent().get_node("Player").position.y
		moving = true
	go_to_destination(delta)
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
	track_player = true
	
#	var random_y_position = rng.randf_range(LASER_UPPER_BOUNDRY, LASER_LOWER_BOUNDRY)
#	destination_position.y = random_y_position
	moving = true
	attack_timer = Timer.new()
	attack_timer.set_wait_time(5)
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(laser_attack)
	add_child(attack_timer)
	attack_timer.start()

func laser_attack():
	print("attack")
	moving = false
	track_player = false
	current_state = State.ATTACK
	attack_timer = Timer.new()
	attack_timer.set_wait_time(laser_attack_time)
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(finish_attack)
	add_child(attack_timer)
	attack_timer.start()

func finish_attack():
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
	active = false

######################################################33

func set_move_speed(new_move_speed: int):
	move_speed = new_move_speed
	
func get_move_speed():
	return move_speed
