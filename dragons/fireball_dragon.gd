extends CharacterBody2D

const PRINT = false

enum State {
	DEFAULT,
	ATTACK
}

@export var move_speed = 125.0
@export var moving = false
@export var current_state = State.DEFAULT
@export var fireball_attack_time = 2.0

var fireball_scene = preload("res://dragons/fireball.tscn")

var destination_position
var attack_timer = null
var attack_started = false				# temporary
var attack_finished = false
var active = false

###### SYSTEM FUNCTIONS ######

func _ready():
	position = $InitialPosition.position
	$AnimatedSprite2D.play("default")

func _physics_process(delta):
	if not moving and attack_finished:
		_print("Fireball dragon finished attacking")
		attack_started = false
		attack_finished = false
	if not moving and position == $ExitPosition.position:
		position = $InitialPosition.position
		active = false

	_go_to_destination(delta)
	move_and_slide()

###### PUBLIC FUNCTIONS ######

func activate(speed=125.0):
	if not active:
		destination_position = $DefaultPosition.position
		moving = true
		active = true
		move_speed = speed
	else:
		_print("Activate: Fireball dragon is already active")

func start_attack():
	if attack_started:
		_print("Start_attack: Fireball dragon is already attacking")
		return null

	attack_started = true
	destination_position = $FireballAttackPosition.position
	moving = true
	
	attack_timer = Timer.new()
	attack_timer.set_wait_time(_calculate_movement_time() + 100 / move_speed)
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(_fireball_attack)
	add_child(attack_timer)
	attack_timer.start()

func deactivate():
	if attack_started:
		_print("Deactivate: Fireball dragon is still attacking")
		return null
	
	move_speed = 800
	destination_position = $ExitPosition.position
	moving = true

###### PRIVATE FUNCTIONS ######

func _fireball_attack():
	for v in [300, 500, 700, 900, 1100]:
		var fireball = fireball_scene.instantiate()
		fireball.init(v)
		fireball.position = position + Vector2(150, -50)
		get_parent().add_child(fireball)
		get_parent().move_child(fireball, 4)
	
	current_state = State.ATTACK
	attack_timer = Timer.new()
	attack_timer.set_wait_time(fireball_attack_time)
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(_finish_attack)
	add_child(attack_timer)
	attack_timer.start()

func _finish_attack():
	destination_position = $DefaultPosition.position
	moving = true
	attack_finished = true
	current_state = State.DEFAULT
	
func _go_to_destination(delta):
	if moving:
		var direction = destination_position - position
		var distance = direction.length()
		var movement = direction.normalized() * min(distance, move_speed * delta)
		position += movement
	if position == destination_position:
		moving = false

func _calculate_movement_time():
	var direction = destination_position - position
	var distance = direction.length()
	return distance / move_speed
	
func _print(message):
	if PRINT:
		print(message)
