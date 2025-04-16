@tool
class_name TowerRoomSeparator
extends Line2D

var light_occluder_2d : LightOccluder2D
var added_extra_points : bool = false
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

func _process(_delta: float) -> void:
	_set_occluder_points()

func _set_occluder_points() -> void:
	if Engine.is_editor_hint():
		if get_point_count() > 2:
			light_occluder_2d.occluder.polygon = points
			return
	if not added_extra_points:
		_add_extra_points()
		added_extra_points = true
	if get_point_count() > 2:
		if GlobalVars.player_light == null or GlobalVars.camera == null:
			return
		var viewport_rect : Rect2 = get_viewport_rect()
		var pt0 : Vector2 = points[1] + global_position
		var pt1 : Vector2 = points[get_point_count() - 2] + global_position
		var first_point = project_point_onto_viewport(pt0, GlobalVars.player_light.global_position) - global_position
		var last_point = project_point_onto_viewport(pt1, GlobalVars.player_light.global_position) - global_position
		set_point_position(0, first_point)
		set_point_position(get_point_count() - 1, last_point)
		light_occluder_2d.occluder.polygon = points

func _add_extra_points() -> void:
	add_point(points[0], 0)
	add_point(points[get_point_count() - 1])



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

func project_point_onto_viewport(point: Vector2, origin: Vector2) -> Vector2:
	var dir: Vector2 = origin.direction_to(point)
	# Get the camera's world-space viewport rect
	var camera_pos = GlobalVars.camera.global_position
	var zoom = GlobalVars.camera.zoom
	var viewport_size : Vector2 = get_viewport().size
	var half_extents : Vector2 = viewport_size * 0.5 / zoom

	var min : Vector2 = camera_pos - half_extents
	var max : Vector2 = camera_pos + half_extents
	var rect : Rect2 = Rect2(min, viewport_size / zoom)
	if not rect.has_point(point):
		return point
	# Define viewport edges as segments (top, right, bottom, left)
	var edges = [
		[min, Vector2(max.x, min.y)], # top
		[Vector2(max.x, min.y), max], # right
		[max, Vector2(min.x, max.y)], # bottom
		[Vector2(min.x, max.y), min]  # left
	]

	var closest_point: Vector2 = point
	var min_dist = INF
	var ray_end = origin + dir * 10000 # simulate a far away point

	for edge in edges:
		var inter = Geometry2D.segment_intersects_segment(origin, ray_end, edge[0], edge[1])
		if inter != null:
			var dist = origin.distance_squared_to(inter)
			if dist < min_dist:
				min_dist = dist
				closest_point = inter
	return closest_point + dir / zoom
