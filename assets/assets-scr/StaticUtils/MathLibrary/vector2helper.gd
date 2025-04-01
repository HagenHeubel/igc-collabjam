class_name V2_Util
extends RefCounted # vector2helper


## Useful functions to simplify working with Vector2 values

static var directions_v2 = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
static var horizontal_directions_v2 = [Vector2.LEFT, Vector2.RIGHT]
static var vertical_directions_v2 = [Vector2.UP, Vector2.DOWN]


static var opposite_directions_v2 = {
	Vector2.UP: Vector2.DOWN,
	Vector2.DOWN: Vector2.UP,
	Vector2.RIGHT: Vector2.LEFT,
	Vector2.LEFT: Vector2.RIGHT
}


static func up_direction_opposite_vector2(up_direction: Vector2) -> Vector2:
	if opposite_directions_v2.has(up_direction):
		return opposite_directions_v2[up_direction]

	return Vector2.ZERO


static func generate_2d_random_directions_using_degrees(num_directions: int = 10, origin: Vector2 = Vector2.UP, min_angle: float = 0.0, max_angle: float = 360.0) -> Array[Vector2]:
	var random_directions: Array[Vector2] = []

	for direction in range(num_directions):
		random_directions.append(origin.rotated(generate_random_angle_in_degrees(min_angle, max_angle)))

	return random_directions


static func generate_2d_random_directions_using_radians(num_directions: int = 10, origin: Vector2 = Vector2.UP, min_angle: float = 0.0, max_angle: float = 6.2831853072) -> Array[Vector2]:
	var random_directions: Array[Vector2] = []

	for direction in range(num_directions):
		random_directions.append(origin.rotated(generate_random_angle_in_radians(min_angle, max_angle)))

	return random_directions

static func generate_random_angle_in_radians(min_angle: float = 0.0, max_angle: float = 6.2831853072) -> float:
	return min_angle + randf() * (max_angle - min_angle)


static func generate_random_angle_in_degrees(min_angle: float = 0.0, max_angle: float = 360.0) -> float:
	return min_angle + randf() * (max_angle - min_angle)


static func generate_2d_random_fixed_direction() -> Vector2:
	var direction: Vector2 = Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()

	while direction.is_zero_approx():
		direction =  Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()

	return direction


static func generate_2d_random_direction() -> Vector2:
	return Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()



static func translate_x_axis_to_vector(axis: float) -> Vector2:
	var horizontal_direction = Vector2.ZERO

	match axis:
		-1.0:
			horizontal_direction = Vector2.LEFT
		1.0:
			horizontal_direction = Vector2.RIGHT

	return horizontal_direction


static func translate_y_axis_to_vector(axis: float) -> Vector2:
	var vertical_direction = Vector2.ZERO

	match axis:
		-1.0:
			vertical_direction = Vector2.UP
		1.0:
			vertical_direction = Vector2.DOWN

	return vertical_direction


static func normalize_vector2(value: Vector2) -> Vector2:
		var direction := normalize_diagonal_vector2(value)

		if direction.is_equal_approx(value):
			return value if value.is_normalized() else value.normalized()

		return direction


static func normalize_diagonal_vector2(direction: Vector2) -> Vector2:
	if is_diagonal_direction_v2(direction):
		return direction * sqrt(2)

	return direction


static func is_diagonal_direction_v2(direction: Vector2) -> bool:
	return direction.x != 0 and direction.y != 0


static func is_within_distance_squared_v2(vector: Vector2, second_vector: Vector2, distance: float) -> bool:
	return vector.distance_squared_to(second_vector) <= distance * distance




static func direction_from_rotation_v2(rotation: float) -> Vector2:
	return Vector2(cos(rotation * PI / PI), sin(rotation * PI / PI))



static func direction_from_rotation_degrees_v2(rotation_degrees: float) -> Vector2:
	rotation_degrees = deg_to_rad(rotation_degrees)
	var pi_degrees := deg_to_rad(PI)

	return Vector2(cos(rotation_degrees * pi_degrees / pi_degrees), sin(rotation_degrees * pi_degrees / pi_degrees))



## Also known as the "city distance" or "L1 distance".
## It measures the distance between two points as the sum of the absolute differences of their coordinates in each dimension.
##
static func distance_manhattan_v2(a: Vector2, b: Vector2) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

## Also known as the "chess distance" or "L∞ distance".
## It measures the distance between two points as the greater of the absolute differences of their coordinates in each dimension
static func distance_chebyshev_v2(a: Vector2, b: Vector2) -> float:
	return max(abs(a.x - b.x), abs(a.y - b.y))


static func length_manhattan_v2(a : Vector2) -> float:
	return abs(a.x) + abs(a.y)


static func length_chebyshev_v2(a : Vector2) -> float:
	return max(abs(a.x), abs(a.y))

## This function calculates the closest point on a line segment (defined by two points, a and b) to a third point c.
## It also clamps the result to ensure that the closest point lies within the line segment.
static func closest_point_on_line_clamped_v2(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	b = (b - a).normalized()
	c = c - a
	return a + b * clamp(c.dot(b), 0.0, 1.0)

## This function is similar to the previous one but does not clamp the result.
## It calculates the closest point on the line segment defined by a and b to a third point c.
## It uses the same vector operations as the previous closest_point_on_line_clamped_v2 function.
static func closest_point_on_line_v2(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	b = (b - a).normalized()
	c = c - a

	return a + b * (c.dot(b))
