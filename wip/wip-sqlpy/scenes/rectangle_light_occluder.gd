@tool
class_name LightOccluderRect
extends LightOccluder2D

@export var rect_collision_shape : CollisionShape2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not rect_collision_shape:
		return
	if not occluder:
		occluder = OccluderPolygon2D.new()
		occluder.resource_local_to_scene = true
		occluder.cull_mode = OccluderPolygon2D.CULL_COUNTER_CLOCKWISE
	occluder.polygon = Util.get_rect_points((rect_collision_shape.shape as RectangleShape2D).get_rect())
	position = rect_collision_shape.position
