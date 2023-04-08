extends CharacterBody2D

const PRINT = false

@export var move_speed = 125.0
@export var moving = false
@export var current_state = State.DEFAULT
@export var laser_attack_time = 1.5

enum State {
	DEFAULT,
	ATTACK,
	START_ATTACK,
	END_ATTACK
}

var destination_position
var attack_timer = null
var attack_started = false
var attack_finished = false
var active = false
var is_firing = false
var track_player = false

var laser_scene = preload("res://dragons/laser.tscn")
var laser

###### SYSTEM FUNCTIONS ######

func _ready():
	position = $InitialPosition.position
	$AnimatedSprite2D.play("default")
	
func _physics_process(delta):
	if not moving and attack_finished:
		_print("Laser dragon finished attacking")
		attack_started = false
		attack_finished = false
	if not moving and position == $ExitPosition.position:
		position = $InitialPosition.position
		active = false
	if track_player:
		destination_position.y = get_parent().get_node("Player").position.y
		moving = true
		
	_go_to_destination(delta)
	move_and_slide()

###### PUBLIC FUNCTIONS ######

func activate(speed):
	if active:
		_print("Activate: Laser dragon is already active")
		return null

	destination_position = $DefaultPosition.position
	moving = true
	active = true
	move_speed = speed
	_change_state(State.DEFAULT)

func start_attack():
	if attack_started:
		_print("Start_attack: Laser dragon is already attacking")
		return null
	
	_print("Start_attack: Laser dragon started attacking")
	_change_state(State.START_ATTACK)
	attack_started = true
	track_player = true
	moving = true
	
	attack_timer = Timer.new()
	attack_timer.set_wait_time(1.5)
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(_laser_attack)
	add_child(attack_timer)
	attack_timer.start()

func deactivate():
	if attack_started:
		_print("Deactivate: Laser dragon is still attacking")
		return null
	
	move_speed = 800
	destination_position = $ExitPosition.position
	moving = true

###### PRIVATE FUNCTIONS ######

func _laser_attack():
	is_firing = true
	moving = false
	track_player = false
	
	attack_timer = Timer.new()
	attack_timer.set_wait_time(laser_attack_time)
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(_finish_attack)
	add_child(attack_timer)
	attack_timer.start()

func _finish_attack():
	destination_position = $DefaultPosition.position
	moving = true
	attack_finished = true
	is_firing = false
	
	laser.queue_free()
	_change_state(State.DEFAULT)

func _go_to_destination(delta):
	if moving:
		var direction = destination_position - position
		var distance = direction.length()
		var movement = direction.normalized() * min(distance, move_speed * delta)
		position += movement
	if position == destination_position:
		moving = false

func _on_animation_looped():
	if is_firing:
		laser = laser_scene.instantiate()
		laser.position = position + Vector2(1075, 0)
		get_parent().add_child(laser)
		get_parent().move_child(laser, 2)
		is_firing = false

func _change_state(new_state):
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
		_change_state(State.ATTACK)
	elif current_state == State.END_ATTACK:
		_change_state(State.DEFAULT)
		
func _print(message):
	if PRINT:
		print(message)

###### NOT IN USE ######

#func _calculate_movement_time():
#	var direction = destination_position - position
#	var distance = direction.length()
#	return distance / move_speed
