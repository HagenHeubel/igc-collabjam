extends RigidBody2D

@onready var soft_pin: SoftPin = $SoftPin

var target_position : Vector2

func _process(delta: float) -> void:
	soft_pin.reference_position = Util.delta_lerp_vec2(soft_pin.reference_position, target_position, 6.0, delta)
