extends TextureRect

@onready var collision_shape_2d: CollisionShape2D = $"../CollisionShape2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	size = collision_shape_2d.shape.size
	global_position = collision_shape_2d.global_position - size / 2.0
