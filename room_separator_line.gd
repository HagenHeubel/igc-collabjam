@tool
class_name TowerRoomSeparator
extends Line2D

var light_occluder_2d : LightOccluder2D
const TOWER_ROOM_SEPARATOR_TEXTURE = preload("res://wip/wip-sqlpy/assets/tower_room_separator_texture.tres")

func _ready() -> void:
	var child : LightOccluder2D
	if get_child_count() == 0:
		child = LightOccluder2D.new()
		add_child(child, false, Node.INTERNAL_MODE_FRONT)
	else:
		child = get_child(0)
	light_occluder_2d = child
	
	_set_light_occluder_settings()
	_set_line_settings()
	_set_occluder_points()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_set_occluder_points()

func _set_occluder_points() -> void:
	if get_point_count() > 2:
		light_occluder_2d.occluder.polygon = points

func _set_light_occluder_settings() -> void:
	if light_occluder_2d.occluder == null:
		light_occluder_2d.occluder = OccluderPolygon2D.new()
	light_occluder_2d.occluder.closed = false
	light_occluder_2d.sdf_collision = false

func _set_line_settings() -> void:
	z_index = 1
	width = 16
	texture = TOWER_ROOM_SEPARATOR_TEXTURE
	texture_mode = Line2D.LINE_TEXTURE_STRETCH
	joint_mode = Line2D.LINE_JOINT_ROUND
