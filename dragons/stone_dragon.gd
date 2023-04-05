extends CharacterBody2D

const PRINT = false

@export var move_speed = 125.0
@export var moving = false
@export var current_state = State.DEFAULT

enum State {
	DEFAULT,
	ATTACK
}

var destination_position
var attack_timer = null
var attack_started = false
var attack_finished = false
var track_player = false
var active = false
var attack_speed = move_speed
var reload_speed = 600
var stones_to_shot = 3
var stones_left = 0

###### SYSTEM FUNCTIONS ######

func _ready():
	position = $InitialPosition.position
	$AnimatedSprite2D.play("default")

func _physics_process(delta):
	if not moving and attack_finished:
		_print("Stone dragon finished attacking")
		attack_started = false
		attack_finished = false
		_change_state(State.DEFAULT)
		destination_position = $DefaultPosition.position
		moving = true
		move_speed = attack_speed
	if track_player:
		destination_position.x = get_parent().get_node("Player").position.x + 40
		moving = true
	if not moving and position == $ExitPosition.position:
		position = $InitialPosition.position
		active = false
	_go_to_destination(delta)
	move_and_slide()

###### PUBLIC FUNCTIONS ######

func activate(speed):
	if active:
		_print("Activate: Stone dragon is already active")
		return null
	
	destination_position = $DefaultPosition.position
	moving = true
	active = true
	move_speed = speed + 50.0
	attack_speed = move_speed
	_change_state(State.DEFAULT)

func start_attack():
	if moving or attack_started:
		_print("Start_attack: Stone dragon is already attacking")
		return null

	destination_position = $StoneAttackPosition.position
	moving = true
	attack_started = true
	stones_left = stones_to_shot
	
	attack_timer = Timer.new()
	attack_timer.set_wait_time(_calculate_movement_time())
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(_stone_attack)
	add_child(attack_timer)
	attack_timer.start()

func deactivate():
	if attack_started:
		_print("Deactivate: Stone dragon is still attacking")
		return null
	
	move_speed = 800
	destination_position = $ExitPosition.position
	moving = true

###### PRIVATE FUNCTIONS ######

func _stone_attack():
	attack_timer = Timer.new()
	if stones_left == stones_to_shot:
		track_player = true
		stones_left -= 1
		attack_timer.set_wait_time(400 / move_speed)
		attack_timer.timeout.connect(_stone_attack)
	elif stones_left >= 0:
		if stones_left == 0:
			_change_state(State.ATTACK)
		
		stones_left -= 1
		var stone = preload("res://dragons/stone.tscn").instantiate()
		stone.position = position + Vector2(0, 100)
		stone.set_speed(get_parent().get_node("DangerScheduler").segment_speed)
		get_parent().add_child(stone)
		
		attack_timer.set_wait_time(400 / move_speed)
		attack_timer.timeout.connect(_stone_attack)
	else:
		track_player = false
		attack_timer.set_wait_time(100 / move_speed)
		attack_timer.timeout.connect(_finish_attack)
		
	attack_timer.set_one_shot(true)
	add_child(attack_timer)
	attack_timer.start()

func _finish_attack():
	destination_position = $InitialPosition.position
	moving = true
	attack_finished = true
	move_speed = reload_speed

func _calculate_movement_time():
	var direction = destination_position - position
	var distance = direction.length()
	return distance / move_speed

func _change_state(new_state):
	if current_state == new_state:
		return null
	current_state = new_state
	if current_state == State.DEFAULT:
		$AnimatedSprite2D.play("default")
	if current_state == State.ATTACK:
		$AnimatedSprite2D.play("attack")

func _go_to_destination(delta):
	if moving:
		var direction = destination_position - position
		var distance = direction.length()
		var movement = direction.normalized() * min(distance, move_speed * delta)
		position += movement
	if position == destination_position:
		moving = false
		
func _print(message):
	if PRINT:
		print(message)


