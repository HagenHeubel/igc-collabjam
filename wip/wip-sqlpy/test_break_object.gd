extends RigidBody2D

@onready var breaks_on_impact: BreaksOnImpact = $BreaksOnImpact
@onready var particles: GPUParticles2D = $Particles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	breaks_on_impact.break_triggered.connect(_on_broken)

func _on_broken(impact : Vector2) -> void:
	particles.look_at(particles.global_position + Vector2.UP)
	particles.one_shot = true
	var process_material : ParticleProcessMaterial = particles.process_material
	process_material.initial_velocity_min = impact.length() * 0.1
	process_material.initial_velocity_max = impact.length() * 0.5
	particles.emitting = true
	collision_layer = 0
	collision_mask = 0
	await particles.finished
	queue_free()
	
