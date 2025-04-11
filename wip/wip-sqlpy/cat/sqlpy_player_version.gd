extends RigidBody2D
class_name SQLPYPlayer2D

signal harmed()
signal healed()
signal died()

@export var interaction_detect: InteractionDetector

@export_group("Stats")
@export var HEALTH_MAX: int = 9
@export var move_force: float = 14000.0
@export var jump_impulse_strength: float = 5000.0
@export_range(30.0, 60.0, 1.0) var slope_angle_max: float = 45.0  # In degrees; converted to radians in _ready()
@export_range(0.0, 3.0, 0.1) var rotation_stabilizer: float = 1.0

@export_group("Pounce Controls")
@export_range(0.2, 4.0, 0.05) var charge_time: float = 1.0  # Seconds until charge is full
@export_enum("Left/Right", "Up/Down", "Mouse Targeting", "Mouse Delta", "Mouse Delta XY", "Mouse Left/Right", "Charged Targeting")
var pounce_control_type: int = 0
@export var charge_always_full: bool = false
@export_range(0.0, 0.7) var min_jump_charge: float = 0.3
@export_range(0.1, 0.9, 0.05) var h_jump_control: float = 0.7
@export_range(0.5, 3.0) var pounce_movement_boost: float = 1.5 
@export_range(45, 180.0, 5.0) var pounce_aim_speed: float = 130.0
@export_range(5.0, 40.0, 0.5) var min_pounce_angle: float = 15.0
@export_range(5.0, 90.0, 0.5) var def_pounce_angle: float = 45.0
@export_range(50.0, 90.0, 0.5) var max_pounce_angle: float = 85.0

@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var ground_detect_left: RayCast2D = $GroundDetectLeft
@onready var ground_detect_middle: RayCast2D = $GroundDetectMiddle
@onready var ground_detect_right: RayCast2D = $GroundDetectRight

var health: int = HEALTH_MAX
var respawn_position: Vector2 = global_position

var get_pounce_rotation_input: Callable
var default_gravity_scale: float = self.gravity_scale
var is_on_floor: bool = false
var is_on_wall: bool = false
var neutral_force: Vector2
var jump_charge: float = min_jump_charge
var current_movement_boost: float = 0.0
var mouse_delta: Vector2 = Vector2.ZERO


func _ready() -> void:
	GlobalVars.player = self

	if not interaction_detect:
		push_error("No interaction detector assigned in player script", self)
	
	# Calculate gravity-neutralizing constant force.
	neutral_force = Vector2(0.0, gravity * default_gravity_scale * -3.1)
	constant_force = neutral_force * 0  # Effectively a zero vector
	
	# Convert slope angle from degrees to radians.
	slope_angle_max = deg_to_rad(slope_angle_max)
	# Convert charge time into a multiplier.
	charge_time = 1.0 / charge_time

	match pounce_control_type:
		0:
			get_pounce_rotation_input = pounce_rotation_left_right
		1:
			get_pounce_rotation_input = pounce_rotation_up_down
		2:
			get_pounce_rotation_input = pounce_rotation_mouse_targeting
		3:
			get_pounce_rotation_input = pounce_rotation_mouse_delta
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		4:
			get_pounce_rotation_input = pounce_rotation_mouse_delta_xy
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		5:
			get_pounce_rotation_input = pounce_rotation_mouse_left_right
		6:
			get_pounce_rotation_input = pounce_rotation_charge_targeting


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	is_on_floor = false
	is_on_wall = false
	for i in range(state.get_contact_count()):
		var contact_normal: Vector2 = state.get_contact_local_normal(i)
		if abs(contact_normal.angle_to(Vector2.UP)) <= (slope_angle_max * 1.2):
			is_on_floor = true
		else:
			is_on_wall = true


func _physics_process(delta: float) -> void:
	var force: Vector2 = Vector2.ZERO
	force.x = Input.get_axis("left", "right")
	
	# Determine the rotation target based on average ground normal.
	var rotation_target: float = clampf(calculate_avg_ground_normal(), -slope_angle_max, slope_angle_max)
	gravity_scale = default_gravity_scale

	if not is_on_floor:
		constant_force = neutral_force * 0  # Zero vector
		force.x *= h_jump_control
	else:
		constant_force = 0.4 * ((-neutral_force).rotated(rotation_target)) + neutral_force
		current_movement_boost = max(current_movement_boost - pounce_movement_boost * delta * 0.75, 0.0)
		
	# Handle jump charging and execution.
	if is_on_floor and Input.is_action_pressed("jump"):
		get_pounce_rotation_input.call(delta)
		force.x = 0.0
		jump_charge = minf(jump_charge + charge_time * delta, 1.0)
	elif is_on_floor and Input.is_action_just_released("jump"):
		if charge_always_full:
			jump_charge = 1.0
		var impulse_direction: Vector2 = Vector2.UP.rotated((PI * 0.5))
		apply_impulse(impulse_direction * jump_impulse_strength * jump_charge)
		current_movement_boost = pounce_movement_boost * jump_charge
		jump_charge = min_jump_charge

	force.x *= move_force * (1.0 + current_movement_boost)
	force = force.rotated(rotation_target)
	apply_force(force)


func take_damage(amount: int) -> void:
	if amount <= 0:
		printerr("You can't take negative damage")
	health -= amount
	harmed.emit()
	if health <= 0:
		health = 0
		die()
	prints(self.name, health)


func heal(amount: int) -> void:
	if amount <= 0:
		printerr("You can't heal a negative amount")
	health += amount
	healed.emit()
	if health >= HEALTH_MAX:
		health = HEALTH_MAX
	prints(self.name, health)


func die() -> void:
	died.emit()
	global_position = respawn_position
	print("Well you should be dead, but vrood didn't get there so here have nine more lives!!")
	heal(9)


func calculate_avg_ground_normal(weigh_side: float = 0.0) -> float:
	var avg_angle: float = 0.0
	if ground_detect_left.is_colliding():
		avg_angle += ground_detect_left.get_collision_normal().angle_to(Vector2.UP) * -minf(weigh_side, -1.0)
	if ground_detect_middle.is_colliding():
		avg_angle += ground_detect_middle.get_collision_normal().angle_to(Vector2.UP)
	if ground_detect_right.is_colliding():
		avg_angle += ground_detect_right.get_collision_normal().angle_to(Vector2.UP) * maxf(weigh_side, 1.0)
	avg_angle /= 3 + abs(weigh_side)
	return -avg_angle


func pounce_rotation_left_right(delta: float) -> float:
	var input_value: float = Input.get_axis("left", "right") * delta * pounce_aim_speed


func pounce_rotation_up_down(delta: float) -> float:
	var input_value: float = Input.get_axis("up", "down") * visual_component.scale.x * delta * pounce_aim_speed


func pounce_rotation_mouse_targeting(delta: float) -> float:
	var rot_to_cursor: float = -get_local_mouse_position().angle_to(Vector2.RIGHT * visual_component.scale.x)
	rot_to_cursor = lerp_angle(visual_component.rotation, rot_to_cursor, 1.0 - exp(-3.1 * delta))
	rot_to_cursor = rad_to_deg(rot_to_cursor)
	if visual_component.scale.x > 0.0:
		return clampf(rot_to_cursor, -max_pounce_angle, -min_pounce_angle)
	else:
		return clampf(rot_to_cursor, min_pounce_angle, max_pounce_angle)


func pounce_rotation_mouse_delta(delta: float) -> float:
	var input_value: float = mouse_delta.y * delta * pounce_aim_speed * 0.05 * visual_component.scale.x
	if visual_component.scale.x > 0.0:
		return clampf(visual_component.rotation_degrees + input_value, -max_pounce_angle, -min_pounce_angle)
	else:
		return clampf(visual_component.rotation_degrees + input_value, min_pounce_angle, max_pounce_angle)


func pounce_rotation_mouse_delta_xy(delta: float) -> float:
	var input_value: float
	if abs(mouse_delta.y) > abs(mouse_delta.x):
		input_value = mouse_delta.y * delta * pounce_aim_speed * 0.05 * visual_component.scale.x
	else:
		input_value = mouse_delta.x * delta * pounce_aim_speed * 0.05
	if visual_component.scale.x > 0.0:
		return clampf(visual_component.rotation_degrees + input_value, -max_pounce_angle, -min_pounce_angle)
	else:
		return clampf(visual_component.rotation_degrees + input_value, min_pounce_angle, max_pounce_angle)


func pounce_rotation_mouse_left_right(delta: float) -> float:
	var input_value: float = 0.0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		input_value -= 1.0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		input_value += 1.0
	input_value *= delta * pounce_aim_speed
	if visual_component.scale.x > 0.0:
		return clampf(visual_component.rotation_degrees + input_value, -max_pounce_angle, -min_pounce_angle)
	else:
		return clampf(visual_component.rotation_degrees + input_value, min_pounce_angle, max_pounce_angle)


func pounce_rotation_charge_targeting(delta: float) -> float:
	var input_value: float = (jump_charge - min_jump_charge + 0.001) / (1.0 - min_jump_charge)
	if visual_component.scale.x > 0.0:
		return rad_to_deg(lerp_angle(deg_to_rad(-min_pounce_angle), deg_to_rad(-max_pounce_angle), input_value))
	else:
		return rad_to_deg(lerp_angle(deg_to_rad(min_pounce_angle), deg_to_rad(max_pounce_angle), input_value))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
