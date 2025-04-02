class_name Util
extends Node

# We can transfer static functions we actually have used into this file so it's easier
# I'll start by putting the lerp functions in here because I will use them guaranteed


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
