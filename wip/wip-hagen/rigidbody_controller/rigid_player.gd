extends RigidBody2D
class_name RigidPlayer2D

signal harmed()
signal healed()
signal died()

@export var interaction_detect: InteractionDetector
@export var visual_component :Node2D
@export_group("Stats")
@export var HEALTH_MAX: int = 9

var health = HEALTH_MAX
var respawn_position = global_position

var default_gravity_scale :float = self.gravity_scale
var on_floor_count :int=false
var on_wall_count :int=false
var is_wall_left :bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !visual_component:
		push_error("No visual component assigned in player script ", self)
	if !interaction_detect:
		push_error("No interaction detector assigned in player script ", self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var force :Vector2 = Vector2.ZERO
	force.x = Input.get_axis("left", "right")
	if (on_floor_count==0):
		force.x *= 0.5
	if (on_wall_count>0) and (on_floor_count==0):
		gravity_scale = default_gravity_scale * 0.2
	else:
		gravity_scale = default_gravity_scale
	
	if force.x < -0.1:
		visual_component.scale.x = -4.0
	elif force.x > 0.1:
		visual_component.scale.x = 4.0
	apply_force(force*14000)
	
	print(linear_velocity)
	
	if (on_floor_count>0) and Input.is_action_just_pressed("jump"):
		apply_impulse(Vector2.UP*5000.0)
	elif (on_wall_count>0) and Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("right") and is_wall_left: #TODO should be checking for input instead
			apply_impulse(Vector2.UP*3000.0)
		if Input.is_action_pressed("left") and !is_wall_left: #TODO should be checking for input instead
			apply_impulse(Vector2.UP*3000.0)


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


func _on_ground_detection_body_entered(body: Node2D) -> void:
	if !(body is RigidPlayer2D):
		on_floor_count += 1
func _on_ground_detection_body_exited(body: Node2D) -> void:
	if !(body is RigidPlayer2D):
		on_floor_count -= 1

func _on_wall_detection_body_entered(body: Node2D) -> void:
	if !(body is RigidPlayer2D):
		on_wall_count += 1
		if (global_position.x - body.global_position.x) > 0.0:
			is_wall_left = false
		else:
			is_wall_left = true
func _on_wall_detection_body_exited(body: Node2D) -> void:
	if !(body is RigidPlayer2D):
		on_wall_count -= 1
