extends RigidBody2D

@onready var breaks_on_impact: BreaksOnImpact = $BreaksOnImpact
@export var particles_triggered_on_break : GPUParticles2D
@export var particle_controller_triggered_on_break : ParticleController
@export var sprite: Sprite2D
@export var trail : Trail2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	breaks_on_impact.break_triggered.connect(_on_break_triggered)

func _on_break_triggered(_break_velocity : Vector2) -> void:
	breaks_on_impact.break_triggered.disconnect(_on_break_triggered)
	if particle_controller_triggered_on_break:
		particle_controller_triggered_on_break.emit_particles()
	if particles_triggered_on_break:
		particles_triggered_on_break.emitting = true
	if sprite:
		sprite.hide()
	if trail:
		trail.create_new_points = false
		trail.remove_newest_point()
	collision_mask = 0
	collision_layer = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	gravity_scale = 0
