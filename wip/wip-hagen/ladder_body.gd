extends CharacterBody2D

@onready var ladder_scene :LibraryLadder= get_parent()

var resistance = 0.2
var recent_push_strength:float

func _physics_process(delta: float) -> void:
	velocity.x=recent_push_strength*delta
	recent_push_strength = 0.999
	
	if position.x < ladder_scene.rail_left.position.x:
		velocity.x = maxf(velocity.x,0.0)
	elif position.x > ladder_scene.rail_left.position.x:
		velocity.x = minf(velocity.x,0.0)
	move_and_slide()
	_push_rigid_bodies()

func _push_rigid_bodies() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			recent_push_strength = collider.linear_velocity.x*(1.0-resistance)*abs(collision.get_normal().x)
			print("push strength: ",recent_push_strength)
