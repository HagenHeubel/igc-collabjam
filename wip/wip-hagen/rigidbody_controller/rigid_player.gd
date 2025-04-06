extends RigidBody2D
class_name RigidPlayer2D

signal harmed()
signal healed()
signal died()

@export var interaction_detect: InteractionDetector
@export var visual_component :Node2D
@export_group("Stats")
@export var HEALTH_MAX: int = 9
@export var move_force :float= 14000.0
@export var jump_impulse_strength :float=5000.0
@export var slope_angle_max :float= 45##How far the char's rotation can adjust to slopes[br]In degrees, but will be converted into rads inside of _ready()

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var ground_detect_left: RayCast2D = %GroundDetectLeft
@onready var ground_detect_middle: RayCast2D = %GroundDetectMiddle
@onready var ground_detect_right: RayCast2D = %GroundDetectRight


var health = HEALTH_MAX
var respawn_position = global_position

var default_gravity_scale :float = self.gravity_scale
var on_floor_count :int=false
var on_wall_count :int=false
var is_wall_left :bool=false
var neutral_force :Vector2


func _ready() -> void:
	GlobalVars.player = self
	
	#push errrors if exported references haven't been assigned
	if !visual_component:
		push_error("No visual component assigned in player script ", self)
	if !interaction_detect:
		push_error("No interaction detector assigned in player script ", self)
	
	#calculate gravity-neutralizing constant force 
	neutral_force = Vector2(0.0,gravity*default_gravity_scale*-3.1)
	#neutral force negated becomes gravity, necessary for later rotation
	constant_force = neutral_force + neutral_force*-1
	#change degrees to radians for more efficient code
	slope_angle_max = deg_to_rad(slope_angle_max)


func _integrate_forces(state: PhysicsDirectBodyState2D):
	on_floor_count = 0
	on_wall_count = 0
	var floor_detected:bool=false
	var wall_detected:bool=false
	for i in range(state.get_contact_count()): 
		if abs(state.get_contact_local_normal(i).angle_to(Vector2.UP)) <= (slope_angle_max*1.2):
			floor_detected = true
			on_floor_count += 1
		else:
			wall_detected = true
			on_wall_count += 1
	on_floor_count = floor_detected

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#check_floor()
	
	var force :Vector2 = Vector2.ZERO
	force.x = Input.get_axis("left", "right")
	var rotation_target = clampf(calculate_avg_ground_normal(),-slope_angle_max,slope_angle_max)
	
	if (on_floor_count==0):
		constant_force = neutral_force + neutral_force*-1
		force.x *= 0.7
		if (on_wall_count>0): #slow down gravity while hanging on wall
			gravity_scale = default_gravity_scale * 0.3
		else: #reset gravity while airborne and not on wall
			gravity_scale = default_gravity_scale
	else: #tune down gravity on floor (largely to avoid sliding down slopes)
		gravity_scale = default_gravity_scale
		constant_force = 0.4*(-neutral_force).rotated(rotation_target) + neutral_force 
	
	#if rotation > 0.3:
		#apply_torque(-100010.1)
	#elif rotation < -0.3:
		#apply_torque(100010.1)
	if rotation > (rotation_target+0.3):
		apply_torque(-50010.1)
	elif rotation < (rotation_target-0.3):
		apply_torque(50010.1)
	
	if force.x < -0.1:
		visual_component.scale.x = -4.0
	elif force.x > 0.1:
		visual_component.scale.x = 4.0
	#print("force before rotation: ", force)
	#force.y = get_gravity().y *-1
	#print(get_gravity())
	force.x *= move_force
	force = force.rotated(rotation_target) 
	apply_force(force)
	
	if (on_floor_count>0) and Input.is_action_just_pressed("jump"):
		apply_impulse(Vector2.UP.rotated(rotation_target*0.4)*jump_impulse_strength)
	elif (on_wall_count>0) and Input.is_action_just_pressed("jump"):
		apply_impulse(Vector2.UP.rotated(rotation_target)*jump_impulse_strength*0.7)

##Reduces health and emits harmed signal
func take_damage(amount: int) -> void:
	if amount <= 0: 
		printerr("You can't take negative damage")
	health -= amount
	harmed.emit()
	if health <= 0:
		health = 0
		die()
	prints(self.name, health)

##Increases health up to HEALTH_MAX and emits healed signal
func heal(amount: int) -> void:
	if amount <= 0:
		printerr("You can't heal a negative amount")
	health += amount
	healed.emit()
	if health >= HEALTH_MAX:
		health = HEALTH_MAX
	prints(self.name, health)

##Emits died signal, heals the player back up and resets location
func die() -> void:
	died.emit()
	global_position = respawn_position
	print("Well you should be dead, but vrood didn't get there so here have nine more lives!!")
	heal(9)


func check_floor():
	if ground_detect_left.is_colliding() or ground_detect_middle.is_colliding() or ground_detect_right.is_colliding():
		on_floor_count = 1
	else:
		on_floor_count = 0
	print(on_floor_count)


func calculate_avg_ground_normal(weigh_side:float=0.0)->float:
	var avg_angle:float=0.0
	avg_angle += ground_detect_left.get_collision_normal().angle_to(Vector2.UP)*(-1)*minf(weigh_side, -1.0)
	avg_angle += ground_detect_middle.get_collision_normal().angle_to(Vector2.UP)
	avg_angle += ground_detect_right.get_collision_normal().angle_to(Vector2.UP)*maxf(weigh_side, 1.0)
	#avg_angle -= rotation
	avg_angle /= 3+abs(weigh_side)
	return -avg_angle
