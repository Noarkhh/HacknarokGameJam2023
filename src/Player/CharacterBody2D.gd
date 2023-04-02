extends CharacterBody2D


const MAX_SPEED = 400.0
const SPEED_ACCELERATION = 30.0
const JUMP_VELOCITY = -800.0
const MAX_FALLING_SPEED = 800.0

const COLLISION_RUN_TO_ROLL = Vector2(1, 0.5)
const COLLISION_ROLL_TO_RUN = Vector2(1, 2)
const COLLISION_RUN_TO_SLIDE = Vector2(2, 0.5)
const COLLISION_SLIDE_TO_RUN = Vector2(0.5, 2)
const ROLL_DURATION = 20
var current_roll_time = 0
var is_rolling = false

var enable_double_jump = true

var enable_extra_speed = true
var extra_speed = 50.0
#var used_double_jump = true

const DASH_DURATION = 6
const DASH_COOLDOWN = 300
var time_since_last_dash = 300
var is_dashing = false
var is_sliding = false
var dash_velocity = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#func _input(event):
#	print(event.as_text()) 

func _ready():
	$Player.play()

func _physics_process(delta):
	
	if is_dashing:
		velocity.x += dash_velocity
		time_since_last_dash += 1
	
		move_and_slide()
		if time_since_last_dash > DASH_DURATION:
			is_dashing = false
			velocity.x = MAX_SPEED
		else:
			return
		
	if enable_extra_speed:
		extra_speed = 50.0
	else:
		extra_speed = 0.0
		
	# Add the gravity.
	if not is_on_floor():
		if enable_double_jump and Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
			enable_double_jump = false
			$CollisionShape2D.apply_scale(COLLISION_RUN_TO_ROLL)
			print("STARTED ROLLING")
			# TODO roll animation
			
			is_rolling = true
			current_roll_time = 0
		else:
			velocity.y += gravity * delta
			velocity.y = min(velocity.y, MAX_FALLING_SPEED)
			current_roll_time += 1
			if current_roll_time > ROLL_DURATION and is_rolling:
				print("STOPPED ROLLING")
				$CollisionShape2D.apply_scale(COLLISION_ROLL_TO_RUN)
				is_rolling = false
	else:
		if Input.get_action_strength("key_s") and not is_sliding:
			print("STARTED SLIDING")
			$CollisionShape2D.apply_scale(COLLISION_RUN_TO_SLIDE)
			# TODO ANIMACJA 
			is_sliding = true
		elif not Input.get_action_strength("key_s") and is_sliding:
			print("STOPPED SLIDING")
			$CollisionShape2D.apply_scale(COLLISION_SLIDE_TO_RUN)
			is_sliding = false
		enable_double_jump = true
		

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("key_a", "key_d")
	if direction:
		if Input.get_action_strength("key_shift") and time_since_last_dash > DASH_COOLDOWN:
			time_since_last_dash = 1
			is_dashing = true
			dash_velocity =  direction * MAX_SPEED
			velocity.x += dash_velocity
		else:
			if (velocity.x < 0 and 0 < direction) or (direction < 0 and 0 < velocity.x):
				velocity.x += direction * SPEED_ACCELERATION * 3
			else:
				velocity.x += direction * SPEED_ACCELERATION
				velocity.x = min(abs(velocity.x), MAX_SPEED + extra_speed) * direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED_ACCELERATION)  # from, to, speed
		
	time_since_last_dash += 1

#	print(velocity)
	move_and_slide()
