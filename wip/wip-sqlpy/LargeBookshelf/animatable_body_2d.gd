extends AnimatableBody2D

var target_position : Vector2

func _physics_process(delta: float) -> void:
	global_position = Util.delta_lerp_vec2(global_position, target_position, 6.0, delta)
