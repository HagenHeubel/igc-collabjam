extends PointLight2D

var start_offset : float
@export var color_range : GradientTexture1D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_offset = randf() * 10.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	color = color_range.gradient.sample(remap(sin(Util.get_time_sec() * 0.3 + start_offset), -1.0, 1.0, 0.0, 1.0))
