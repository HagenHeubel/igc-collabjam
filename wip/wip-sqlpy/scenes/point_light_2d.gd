extends PointLight2D

var start_position : Vector2
var target_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = Util.delta_lerp_vec2(position, start_position + Vector2.from_angle(randf_range(0, TAU)) * 5.0, 3.0, delta)
