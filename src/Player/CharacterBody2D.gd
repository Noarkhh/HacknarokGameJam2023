extends CharacterBody2D

const MAX_RIGHT = 1280
const MAX_LEFT = -35

const MAX_SPEED = 400.0
const SPEED_ACCELERATION = 30.0
const JUMP_VELOCITY = -800.0
const MAX_FALLING_SPEED = 800.0

const COLLISION_RUN_TO_ROLL = Vector2(1, 0.5)
const COLLISION_ROLL_TO_RUN = Vector2(1, 2)
const COLLISION_RUN_TO_SLIDE = Vector2(2, 0.5)
const COLLISION_SLIDE_TO_RUN = Vector2(0.5, 2)

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
var last_anim = ""
var is_rolling = false

var health = 3.0
var is_invincible = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#func _input(event):
#	print(event.as_text()) 

func _ready():
	$AnimatedSprite2D.animation = "run"
	$AnimatedSprite2D.play()

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
			velocity.y = JUMP_VELOCITY * 0.85

			enable_double_jump = false
			if not is_rolling:
				$CollisionShape2D.apply_scale(COLLISION_RUN_TO_ROLL)
				print("STARTED ROLLING")
			is_rolling = true
			$AnimatedSprite2D.animation = "start_spin"
			last_anim = "start_spin"
		else:
			velocity.y += gravity * delta
			velocity.y = min(velocity.y, MAX_FALLING_SPEED) #TODO MNIEJ ELO
			
	else:
		if Input.get_action_strength("key_s") and not is_sliding:
			print("STARTED SLIDING")
			$CollisionShape2D.apply_scale(COLLISION_RUN_TO_SLIDE)
			$AnimatedSprite2D.animation = "start_slide"
			is_sliding = true
#			return
		elif not Input.get_action_strength("key_s") and is_sliding:
			print("STOPPED SLIDING")
			$CollisionShape2D.apply_scale(COLLISION_SLIDE_TO_RUN)
			is_sliding = false
			$AnimatedSprite2D.animation = "end_slide"
			last_anim = "end_slide"
		enable_double_jump = true
		if last_anim == "":
			$AnimatedSprite2D.animation = "landing"
			last_anim = "landing"
		

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_sliding:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("key_a", "key_d")
	if direction and not is_sliding:
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
	position.x = min(position.x, MAX_RIGHT)
	if position.x < MAX_LEFT:
		get_tree().paused = true

func _animation_finished():
	if is_sliding:
		$AnimatedSprite2D.animation = "slide"
		$AnimatedSprite2D.play()
	elif last_anim == "end_slide":
		print("XD")
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.play()
	elif last_anim == "start_spin":
		$AnimatedSprite2D.animation = "spin"
		$AnimatedSprite2D.play()
		last_anim = "spin"
	elif last_anim == "spin":
		$AnimatedSprite2D.animation = "end_spin"
		$AnimatedSprite2D.play()
		last_anim = "end_spin"
	elif last_anim == "end_spin":
		print("STOPPED ROLLING")
		is_rolling = false
		$CollisionShape2D.apply_scale(COLLISION_ROLL_TO_RUN)
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.play()
		last_anim = ""
	elif last_anim == "landing":
		$AnimatedSprite2D.animation = "run"
		$AnimatedSprite2D.play()

func player_hit(impact: float) -> void:
	if is_invincible:
		return
	health -= impact
	if health <= 0:
		get_tree().paused = true
	is_invincible = true
	var invincibility_timer = Timer.new()
	invincibility_timer.set_wait_time(2.0)
	invincibility_timer.set_one_shot(true)
	invincibility_timer.timeout.connect(end_invincibility)
	add_child(invincibility_timer)
	invincibility_timer.start()
	get_parent().get_node("UI/HealthBar").health_update(health)
	
func end_invincibility():
	print("ending invincibility")
	is_invincible = false
