class_name Util
extends Node

# We can transfer static functions we actually have used into this file so it's easier
# I'll start by putting the lerp functions in here because I will use them guaranteed


static func get_time_sec() -> float:
	return float(Time.get_ticks_msec()) * 0.001

## Framerate independent lerp functions 
## (Use this over "lerp" for things which should be stable regardless of framerate)

static func delta_lerp(a : float, b : float, exp_decay_val : float, delta : float) -> float:
	return b + (a - b) * exp(-exp_decay_val * delta)

static func delta_lerp_vec2(a : Vector2, b :  Vector2, exp_decay_val : float, delta : float) ->  Vector2:
	a.x = delta_lerp(a.x, b.x, exp_decay_val, delta)
	a.y = delta_lerp(a.y, b.y, exp_decay_val, delta)
	return a

static func delta_lerp_vec3(a : Vector3, b :  Vector3, exp_decay_val : float, delta : float) ->  Vector3:
	a.x = delta_lerp(a.x, b.x, exp_decay_val, delta)
	a.y = delta_lerp(a.y, b.y, exp_decay_val, delta)
	a.z = delta_lerp(a.z, b.z, exp_decay_val, delta)
	return a

static func delta_lerp_color(a: Color, b: Color, exp_decay_val: float, delta: float) -> Color:
	a.r = delta_lerp(a.r, b.r, exp_decay_val, delta)
	a.g = delta_lerp(a.g, b.g, exp_decay_val, delta)
	a.b = delta_lerp(a.b, b.b, exp_decay_val, delta)
	a.a = delta_lerp(a.a, b.a, exp_decay_val, delta)
	return a

static func get_rect_points(rect : Rect2, counter_clockwise : bool = false) -> PackedVector2Array:
	var res : PackedVector2Array = []
	res.append(rect.position)
	res.append(rect.position + rect.size * Vector2.RIGHT)
	res.append(rect.position + rect.size)
	res.append(rect.position + rect.size * Vector2.DOWN)
	if counter_clockwise:
		res.reverse()
	return res

static func clamp_point_to_rect(point: Vector2, rect: Rect2) -> Vector2:
	var clamped_x = clamp(point.x, rect.position.x, rect.position.x + rect.size.x)
	var clamped_y = clamp(point.y, rect.position.y, rect.position.y + rect.size.y)
	return Vector2(clamped_x, clamped_y)

static func manhattan_distance(point_a : Vector2, point_b : Vector2) -> float:
	return abs(point_a.x - point_b.x) + abs(point_b.y - point_a.y)

static func b_spline_from_points(points: Array, num_samples: int, degree: int) -> Array:
	if points.size() < degree + 1:
		push_error("Not enough points for the given degree!")
		return []
		
	var n = points.size() - 1
	var m = n + degree + 1  # highest index for the knot vector
	var knot_vector = []
	
	# Create a uniform knot vector.
	# For a uniform B-spline, we can simply use an increasing sequence.
	for i in range(m + 1):
		knot_vector.append(float(i))
	
	# Parameter t ranges from knot_vector[degree] to knot_vector[m - degree].
	var t_start = knot_vector[degree]
	var t_end = knot_vector[m - degree]
	
	var result = []
	for i in range(num_samples):
		var t = lerp(t_start, t_end, float(i) / float(num_samples - 1))
		var pt = de_boor(points, degree, t, knot_vector)
		result.append(pt)
	return result

static func de_boor(points: Array, degree: int, t: float, knot_vector: Array) -> Vector2:
	var m = knot_vector.size() - 1

	# Find the knot span index k such that knot_vector[k] <= t < knot_vector[k+1].
	# Special case: when t equals the last knot value, set k accordingly.
	var k = degree  # default assignment in case t is at the start
	for i in range(degree, m - degree):
		if t >= knot_vector[i] and t < knot_vector[i + 1]:
			k = i
			break
	if is_equal_approx(t, knot_vector[m - degree]):
		k = m - degree - 1

	# Initialize the de Boor points.
	# d[j] corresponds to control point P[k-degree+j] for j = 0,...,degree.
	var d = []
	for j in range(degree + 1):
		d.append(points[k - degree + j])
	
	# Perform the de Boor recursion.
	for r in range(1, degree + 1):
		for j in range(degree, r - 1, -1):
			var i = k - degree + j
			var denom = knot_vector[i + degree + 1 - r] - knot_vector[i]
			var alpha = 0.0
			if not is_equal_approx(denom, 0.0):
				alpha = (t - knot_vector[i]) / denom
			# Linear interpolation between d[j-1] and d[j].
			d[j] = lerp(d[j - 1],d[j], alpha)
	return d[degree]
