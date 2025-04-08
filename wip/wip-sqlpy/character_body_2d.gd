extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var push_force = 80.0
@onready var cat_sprite: Sprite2D = $CatSprite

func _ready() -> void:
	GlobalVars.player = self

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	if abs(velocity.x) > 0:
		if velocity.x > 0:
			cat_sprite.flip_h = true
		else:
			cat_sprite.flip_h = false
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
