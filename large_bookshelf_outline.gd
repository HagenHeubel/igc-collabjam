@tool
extends Line2D

@onready var large_bookshelf: Line2D = $".."

var last_points : PackedVector2Array
func _ready() -> void:
	last_points = large_bookshelf.points
	redo_points()

func _process(_delta: float) -> void:
	if last_points != large_bookshelf.points:
		last_points = large_bookshelf.points
		redo_points()
		
	
func redo_points() -> void:
	var n : Vector2 = Vector2.from_angle(large_bookshelf.points[0].angle_to_point(large_bookshelf.points[1]) + PI/2.0)
	var w : float   = large_bookshelf.width * 0.5
	clear_points()
	add_point(large_bookshelf.points[0] + n * w)
	add_point(large_bookshelf.points[0] - n * w)
	add_point(large_bookshelf.points[1] - n * w)
	add_point(large_bookshelf.points[1] + n * w)
	var mod_col : Color = (large_bookshelf.material as ShaderMaterial).get_shader_parameter("modulate_color")
	default_color = lerp(mod_col, Color.BLACK, 0.5)
