extends Area2D
class_name InteractionDetector
signal interactable_changed(new_interactable)

@onready var COLLISION_SHAPE: CollisionShape2D = $CollisionShape2D

@export var radius: float = 70.0

# Variable to store the current interactable object
var current_interactable = null

func _ready():
	COLLISION_SHAPE.shape.radius = radius
	set_collision_mask_value(1, false)
	set_collision_mask_value(4, true)
	collision_layer = 0
	monitorable = false

func _physics_process(_delta):
	
	var overlapping_areas = get_overlapping_areas()
	
	# Filter to only interactables
	var interactable_areas = []
	for area in overlapping_areas:
		if area is InteractableComponent:
			interactable_areas.append(area)
	
	# Determine the closest interactable area
	var closest_interactable = null
	if not interactable_areas.is_empty():
		var min_distance = INF
		for interactable in interactable_areas:
			var distance = global_position.distance_to(interactable.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_interactable = interactable
	
	# Update the current interactable
	set_current_interactable(closest_interactable)

# Setter function to update current_interactable and emit signal if changed
func set_current_interactable(value):
	if current_interactable != value:
		current_interactable = value
		interactable_changed.emit(current_interactable)
