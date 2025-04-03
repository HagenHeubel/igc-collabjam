extends CharacterBody2D

signal harmed()
signal healed()
signal died()
@onready var INTERACTION_DETECTOR: InteractionDetector = $InteractionDetector


@export var SPEED = 800.0
@export var ACCELERATION = 1600.0
@export var FRICTION = 1000.0
@export var JUMP_VELOCITY = -420.0
@export var WALL_JUMP_VELOCITY = Vector2(150, -150)
@export var MAX_FALL_SPEED = 1500.0

@export var HEALTH_MAX: int = 9
@export var PUSH_FORCE: float = 500.0
@export var DOUBLE_JUMP_COUNT: int = 1
@export var WALL_SLIDE_SPEED: float = 150.0
@export var WALL_STICKINESS: float = 60.0  # Horizontal push toward wall
@export var COYOTE_TIME: float = 0.1  # Grace period for late jumps
@export var JUMP_BUFFER_TIME: float = 0.1  # Grace period for pre-landing jump input

# Internal variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jumps_left = DOUBLE_JUMP_COUNT
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var is_wall_sliding = false
var was_on_floor_last_frame = false
var health = HEALTH_MAX
var respawn_position = global_position

func take_damage(amount: int) -> void:
	if amount <= 0: 
		printerr("You can't take negative damage")
	health -= amount
	harmed.emit()
	if health <= 0:
		health = 0
		die()
	prints(self.name, health)
	
func heal(amount: int) -> void:
	if amount <= 0:
		printerr("You can't heal a negative amount")
	health += amount
	healed.emit()
	if health >= HEALTH_MAX:
		health = HEALTH_MAX
	prints(self.name, health)

func die() -> void:
	died.emit()
	global_position = respawn_position
	print("Well you should be dead, but vrood didn't get there so here have nine more lives!!")
	heal(9)
	
func handle_movement(delta: float) -> void:
	# Handle Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	else:
		velocity.y = 0.0

	# Horizontal Movement w/ friction and decel
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Update jump timers
	coyote_timer -= delta
	jump_buffer_timer -= delta

	
	if is_on_floor():
		# Reset States when on the ground
		double_jumps_left = DOUBLE_JUMP_COUNT
		coyote_timer = 0.0
		is_wall_sliding = false
		push_rigid_bodies()
		# Start coyote time when leaving ground
	elif was_on_floor_last_frame and not is_on_floor():
		coyote_timer = COYOTE_TIME


		# Wall sliding
	if not is_on_floor() and is_on_wall_only() and velocity.y > 0:
		is_wall_sliding = true
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		# Add stickiness to wall
		var wall_normal = get_wall_normal()
		velocity.x = wall_normal.x * -WALL_STICKINESS
	else:
		is_wall_sliding = false


	# Jumping
	# Trigger Jump Buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	# Detects if Jump Buffer
	if jump_buffer_timer > 0:
		# Coyote Jump
		if coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
		# Double Jump
		elif double_jumps_left > 0 and Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			double_jumps_left -= 1
			jump_buffer_timer = 0
		# Wall Jump	
		elif is_on_wall_only():
			var wall_normal = get_wall_normal()
			velocity = WALL_JUMP_VELOCITY * Vector2(-wall_normal.x, 1)
			jump_buffer_timer = 0

	move_and_slide()
	was_on_floor_last_frame = is_on_floor()

func push_rigid_bodies() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var normal = collision.get_normal()
			var push_strength = max(-velocity.dot(normal), 1) * PUSH_FORCE
			var force = -normal * push_strength
			collider.apply_central_force(force)

func handle_animations(delta: float) -> void:
	pass
	#if !has_node("AnimatedSprite2D"): return
	#
	#var sprite = $AnimatedSprite2D
	#if not is_on_floor():
		#if is_wall_sliding:
			#sprite.play("wall_slide")
			#sprite.flip_h = get_wall_normal().x > 0
		#elif velocity.y < 0:
			#sprite.play("jump")
		#else:
			#sprite.play("fall")
	#else:
		#if abs(velocity.x) > 0.1:
			#sprite.play("run")
			#sprite.flip_h = velocity.x < 0
		#else:
			#sprite.play("idle")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and INTERACTION_DETECTOR.current_interactable:
		INTERACTION_DETECTOR.current_interactable.interact_with()
		
	## Testing Projectile Spawning
	if event.is_action_pressed("ui_down"):
		$"../ProjectileSpawner".spawn_projectile()

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	push_rigid_bodies()
	handle_animations(delta)
	
