@tool
extends Node2D

@export var start_animation : bool = false: set = _start_animation
@export_range(0.0, 1.0, 0.01) var offset : float = 0.0
@onready var path_34: Sprite2D = $Path34
@onready var cat: Sprite2D = $Cat
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2

func _ready() -> void:
	_start_animation(true)


func _start_animation(_val : bool):
	await get_tree().create_timer(5).timeout
	var tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	path_34.material.set_shader_parameter("dissolve_value", 0)
	cat.material.set_shader_parameter("dissolve_value", 0)
	start_animation = false
	tween.tween_callback(path_34.show)
	tween.tween_method(_set_shader_progress, -offset, 0.5, 0.6)
	tween.tween_method(_set_shader_progress, 0.5, 1 + offset, .6)
	tween.tween_callback(path_34.hide)

func _set_shader_progress(val : float) -> void:
	if val > 1.0 + offset / 2.0:
		gpu_particles_2d.emitting = false
	elif val > -1.0:
		gpu_particles_2d.emitting = true
		if val > 0:
			if val > 0.5:
				gpu_particles_2d_2.emitting = true
			else:
				gpu_particles_2d_2.emitting = false
			if val > 0.5 + offset:
				gpu_particles_2d_2.emitting = false
			gpu_particles_2d.amount_ratio = 1.0
		else:
			gpu_particles_2d.amount_ratio = 0.0
	path_34.material.set_shader_parameter("dissolve_value", clamp(val, 0.0, 1.0))
	cat.material.set_shader_parameter("dissolve_value", clamp(val - offset, 0.0, 1.0))
