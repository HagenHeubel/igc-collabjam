class_name ParticleController
extends Node

func emit_particles() -> void:
	for child in get_children():
		child.emitting = true
