@tool
class_name TowerRoomSeparator
extends Line2D

var light_occluder_2d : LightOccluder2D
var added_extra_points : bool = false
var last_first_point : Vector2
var last_last_point : Vector2
const TOWER_ROOM_SEPARATOR_TEXTURE = preload("res://wip/wip-sqlpy/assets/tower_room_separator_texture.tres")

func _ready() -> void:
	added_extra_points = false
	if not Engine.is_editor_hint():
		SignalBus.tower_ready.connect(_on_tower_ready)
	var child : LightOccluder2D
	var children : Array[Node] = get_children()
	for c in children:
		c.queue_free()
	if get_child_count() == 0:
		child = LightOccluder2D.new()
		add_child(child, false)
	else:
		child = get_child(0)
	light_occluder_2d = child
	_set_light_occluder_settings()
	_set_line_settings()
	_set_occluder_points()

func _on_tower_ready() -> void:
	var dupe : LightOccluder2D = light_occluder_2d.duplicate()
	dupe.global_transform = light_occluder_2d.global_transform
	GlobalVars.line_of_sight_world.add_child(dupe)

func _process(_delta: float) -> void:
	if is_node_ready():
		_set_occluder_points()

func _set_occluder_points() -> void:
	if Engine.is_editor_hint():
		if light_occluder_2d:
			if get_point_count() > 2:
				light_occluder_2d.occluder.polygon = points
		return
	if not added_extra_points:
		_add_extra_points()
		added_extra_points = true

	if get_point_count() > 2:
		if not GlobalVars.player_light or not GlobalVars.camera:
			return
		var viewport_rect : Rect2 = get_viewport_rect()
		var pt0 : Vector2 = points[1] + global_position
		var pt01 : Vector2 = points[2] + global_position
		var pt1 : Vector2 = points[get_point_count() - 2] + global_position
		var pt11 : Vector2 = points[get_point_count() - 3] + global_position
		var first_point = project_point_onto_viewport(pt0, GlobalVars.player_light.global_position) - global_position
		var last_point = project_point_onto_viewport(pt1, GlobalVars.player_light.global_position) - global_position
		if get_three_point_angle(first_point, pt0, pt01) > PI/40:
			set_point_position(0, first_point)
			last_first_point = first_point
		else:
			set_point_position(0, last_first_point)
		if get_three_point_angle(pt11, pt1, last_point) > PI/40:
			set_point_position(get_point_count() - 1, last_point)
			last_last_point = last_point
		else:
			set_point_position(get_point_count() - 1, last_last_point)
		var pts : PackedVector2Array = points.duplicate()
		pts = pts.slice(1, pts.size() - 1)
		light_occluder_2d.occluder.polygon = pts

func _add_extra_points() -> void:
	add_point(points[0], 0)
	add_point(points[get_point_count() - 1])

func _set_light_occluder_settings() -> void:
	if light_occluder_2d.occluder == null:
		light_occluder_2d.occluder = OccluderPolygon2D.new()
	light_occluder_2d.occluder.closed = false
	light_occluder_2d.sdf_collision = false
	light_occluder_2d.occluder_light_mask = 4095

func _set_line_settings() -> void:
	z_index = 1
	width = 32
	texture = TOWER_ROOM_SEPARATOR_TEXTURE
	texture_mode = Line2D.LINE_TEXTURE_STRETCH
	joint_mode = Line2D.LINE_JOINT_ROUND
	end_cap_mode = Line2D.LINE_CAP_NONE
	sharp_limit = 200.0


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
	return closest_point + dir / zoom * 100.0

func get_three_point_angle(A: Vector2, B: Vector2, C: Vector2) -> float:
	var v1 = (A - B).normalized()
	var v2 = (C - B).normalized()
	
	var dot = v1.dot(v2)
	
	# Clamp dot product to avoid numerical issues with acos
	dot = clamp(dot, -1.0, 1.0)

	var angle_radians = acos(dot)
	return angle_radians # in radians
