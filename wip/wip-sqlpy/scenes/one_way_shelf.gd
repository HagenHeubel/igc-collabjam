@tool
extends StaticBody2D

@export_range(64, 2048, 1.0, "exp") var width : float = 10.0

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	collision_shape_2d.shape.size.x = width
	collision_shape_2d.position.y = collision_shape_2d.shape.size.y / 2.0
	nine_patch_rect.size.x = width * 1.0/0.118
	nine_patch_rect.position.x = -width / 2.0
