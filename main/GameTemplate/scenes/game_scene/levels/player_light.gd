extends PointLight2D

@export_range(0.1, 30.0, 0.1) var convergence_speed : float = 20.0

func _ready() -> void:
	GlobalVars.player_light = self

func _process(delta: float) -> void:
	var player : Node2D = GlobalVars.player
	if player != null:
		global_position = Util.delta_lerp_vec2(global_position, player.global_position + Vector2.UP * 10.0, convergence_speed, delta)
