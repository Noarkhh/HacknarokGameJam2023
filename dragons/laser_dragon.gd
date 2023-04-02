extends CharacterBody2D

enum State {
	DEFAULT,
	ATTACK,
	START_ATTACK,
	END_ATTACK
}

@export var move_speed = 125.0
@export var moving = false
@export var current_state = State.DEFAULT
@export var laser_attack_time = 2.0

var destination_position
var attack_timer = null
var attack_started = false
var attack_finished = false
var active = false

var track_player = false

func _ready():
	position = $InitialPosition.position
	$AnimatedSprite2D.play("default")
#	activate(move_speed)
	
func activate(speed):
	destination_position = $DefaultPosition.position
	moving = true
	active = true
	move_speed = speed
	change_state(State.DEFAULT)
	
func _physics_process(delta):
	if not moving and attack_finished and attack_started:
		attack_started = false
		attack_finished = false
#	if not moving and active:
#		leave()
		
	if not moving and not active:
		position = $InitialPosition.position
	if track_player:
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
	change_state(State.START_ATTACK)
	attack_started = true
	track_player = true
	
	moving = true
	attack_timer = Timer.new()
	attack_timer.set_wait_time(600 / move_speed)
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(laser_attack)
	add_child(attack_timer)
	attack_timer.start()

func laser_attack():
	print("attack")
	moving = false
	track_player = false
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
	change_state(State.DEFAULT)
	
func calculate_movement_time():
	var direction = destination_position - position
	var distance = direction.length()
	return distance / move_speed

func leave():
	move_speed = 800
	destination_position = $ExitPosition.position
	moving = true
	active = false
	
func change_state(new_state):
	if current_state == new_state:
		return null
	current_state = new_state
	if current_state == State.DEFAULT:
		$AnimatedSprite2D.play("default")
	elif current_state == State.ATTACK:
		$AnimatedSprite2D.play("attack")
	elif current_state == State.START_ATTACK:
		$AnimatedSprite2D.play("attack_begin")
	else:
		$AnimatedSprite2D.play("attack_end")

func _on_animation_finished():
	if current_state == State.START_ATTACK:
		change_state(State.ATTACK)
	elif current_state == State.END_ATTACK:
		change_state(State.DEFAULT)
	
######################################################33

func set_move_speed(new_move_speed):
	move_speed = new_move_speed
	
func get_move_speed():
	return move_speed


