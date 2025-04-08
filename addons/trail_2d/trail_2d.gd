@tool
class_name Trail2D
extends Line2D

@export_category('Trail')
@export var max_points : float = 100
@export var trail_max_time : float = 1.0
@export var clear : bool = false
@export var create_new_points : bool = true
@onready var parent : Node2D = get_parent()
var offset : = Vector2.ZERO
var time_stamps : Array[float] = []

func _ready() -> void:
	clear = true
	offset = position
	top_level = true

func _physics_process(_delta: float) -> void:
	if clear == true:
		clear_points()
		time_stamps.clear()
		clear = false
	global_position = Vector2.ZERO
	_create_new_points()
	_trim_trail()

func _create_new_points() -> void:
	var point : = parent.global_position + offset
	if create_new_points:
		if get_point_count() == 0:
			_add_trail_point(point)
		if point.distance_squared_to(points[0]) > 1.0:
			_add_trail_point(point)

func _add_trail_point(pos : Vector2):
	time_stamps.push_back(Util.get_time_sec())
	add_point(pos, 0)

func _trim_trail() -> void:
	if get_point_count() > max_points:
		_trim_point()
	if get_point_count() == 0:
		return
	if get_point_count() == 0:
		return
	var current_time : float = Util.get_time_sec()
	if current_time > time_stamps[0] + trail_max_time:
		_trim_point()

func _trim_point() -> void:
	remove_point(get_point_count() - 1)
	time_stamps.pop_front()

func remove_newest_point() -> void:
	remove_point(0)
	time_stamps.pop_back()
