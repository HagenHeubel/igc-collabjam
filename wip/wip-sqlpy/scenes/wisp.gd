extends PointLight2D

var start_offset : float
var pos : Vector2
var target_offset : Vector2
@export var color_range : GradientTexture1D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pos = global_position
	start_offset = randf() * 10.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	target_offset += Vector2.from_angle(randf_range(0, TAU)) * delta * 300.0 * randf()
	target_offset = Util.delta_lerp_vec2(target_offset, Vector2.ZERO, 1.0, delta)
	pos = Util.delta_lerp_vec2(pos, get_parent().global_position + target_offset, 2, delta)
	global_position = pos
	color = color_range.gradient.sample(remap(sin(Util.get_time_sec() * 0.3 + start_offset), -1.0, 1.0, 0.0, 1.0))
