@tool
extends RigidBody2D

@export_range(1.0, 256, 1.0) var radius : float = 16

const RADIUS = 16.0

@onready var glass_sphere: Sprite2D = $GlassSphere
@onready var glow_circle: Sprite2D = $GlowCircle
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	collision_shape_2d.shape.radius = radius
	glass_sphere.scale = radius / 530.0 * Vector2.ONE * 2.0
	glow_circle.scale = 0.002 * radius * Vector2.ONE

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		collision_shape_2d.shape.radius = radius
		glass_sphere.scale = radius / 530.0 * Vector2.ONE * 2.0
		glow_circle.scale = 0.002 * radius * Vector2.ONE
