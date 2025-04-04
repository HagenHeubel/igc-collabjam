class_name FallsDownShelves
extends Node

@export var requires_rotation : bool = true
@export var rotation_required : float = 180.0 # Degrees
@export var requires_displacement : bool = false
@export var displacement_required : float = 10.0

## How far the RigidBody has to drop before re-enabeling collision.
@export var min_drop_height : float = 20
# Internal state variables
var parent : RigidBody2D
var start_rotation : float = 0.0 # Radians
var start_x : float = 0.0 # Pixels
var start_y : float = 0.0 # Pixels

var falling : bool = false

func _ready() -> void:
	parent = get_parent()
	if not (parent is RigidBody2D):
		push_error("FallsDownShelves must be a child of a RigidBody2D!")
		return
	# Store initial baseline values
	start_rotation = parent.global_rotation
	start_x = parent.global_position.x
	start_y = parent.global_position.y

func _process(delta: float) -> void:
	if not falling:
		# Check for rotation condition.
		if requires_rotation:
			var rotation_diff = abs(rad_to_deg(parent.global_rotation - start_rotation))
			if rotation_diff >= rotation_required:
				trigger_fall()

		# Check for horizontal displacement condition.
		if requires_displacement:
			var displacement_diff = abs(parent.global_position.x - start_x)
			if displacement_diff >= displacement_required:
				trigger_fall()
	else:
		# While falling, wait until the parent's y value has dropped enough.
		# In Godot, y increases as you go down.
		if parent.global_position.y >= start_y + min_drop_height:
			enable_collision()
			falling = false
			# Store the new baseline values after landing.
			start_rotation = parent.global_rotation
			start_x = parent.global_position.x
			start_y = parent.global_position.y

func trigger_fall() -> void:
	if falling:
		return
	falling = true
	disable_collision()
	# Reset baseline immediately to current values.
	print("Shelf falling triggered")

## -1 +1 is from just toggeling the first collision layer
func disable_collision() -> void:
	parent.collision_mask -= 1

func enable_collision() -> void:
	parent.collision_mask += 1
	start_rotation = parent.global_rotation
	start_x = parent.global_position.x
	start_y = parent.global_position.y
	print("Fall trigger ended")
