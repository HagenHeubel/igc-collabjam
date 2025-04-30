@tool
extends Node2D

@export_range(0.01, 10.0, 0.01) var spawn_interval : float
@export var object_to_spawn : PackedScene
@export_range(-360, 360, 1.0) var min_spawn_angle : float
@export_range(-360, 360, 1.0) var max_spawn_angle : float
@export_range(0, 3000, 10) var min_spawn_velocity : float = 10.0
@export_range(0, 3000, 10) var max_spawn_velocity : float = 10.0
@export var spawn_target : Node2D
var spawning : bool = false
@onready var hint_line_2d: Line2D = $Line2D
@onready var spawn_timer: Timer = $SpawnTimer

var buffer_array : Array[Node] = []

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _ready():
	if Engine.is_editor_hint():
		return
	hint_line_2d.queue_free()
	spawn_timer.start(spawn_interval)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		hint_line_2d.points[1] = Vector2.from_angle(deg_to_rad(min_spawn_angle)) * min_spawn_velocity

func _on_spawn_timer_timeout() -> void:
	var spawn_vector : Vector2 = _generate_spawn_vector()
	if spawning:
		_spawn_object(spawn_vector)

func _generate_spawn_vector() -> Vector2:
	var spawn_velocity : float = randf_range(min_spawn_velocity, max_spawn_velocity)
	var spawn_angle : float = randf_range(min_spawn_angle, max_spawn_angle)
	return Vector2.from_angle(deg_to_rad(spawn_angle)) * spawn_velocity

func _spawn_object(velocity_vector : Vector2) -> void:
	var object : RigidBody2D = object_to_spawn.instantiate()
	spawn_target.add_child(object)
	object.linear_velocity = velocity_vector
	object.global_position = global_position
