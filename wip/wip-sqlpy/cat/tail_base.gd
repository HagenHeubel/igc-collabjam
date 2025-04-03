extends Node2D

@onready var static_body_2d: StaticBody2D = $StaticBody2D

func _physics_process(delta: float) -> void:
	static_body_2d.global_position = lerp(static_body_2d.global_position, get_global_mouse_position(), delta)
