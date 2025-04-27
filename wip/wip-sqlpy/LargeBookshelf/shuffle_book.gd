@tool
class_name ShuffleBook
extends AnimatableBody2D

@export var texture : Texture2D
@export var has_collision : bool = false
@export var slide_gradient : GradientTexture1D
@export_group("Hitbox Reduction", "hitbox")
@export_range(0, 20, 1.0) var hitbox_top : float = 0
@export_range(0, 20, 1.0) var hitbox_bottom : float = 0
@export_range(0, 20, 1.0) var hitbox_right : float = 0
@export_range(0, 20, 1.0) var hitbox_left : float = 0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var left_texture: TextureRect = $LeftTexture
@onready var right_texture: TextureRect = $RightTexture

@onready var gpu_particles_1: GPUParticles2D = $GPUParticles1
@onready var gpu_particles_2: GPUParticles2D = $GPUParticles2

var particle_material : ParticleProcessMaterial
var width : float
var height : float
var tex_width : float
var tex_height : float
var unslot_time : float = 2.5
var position_pause : float = 1.0
var default_collision : int
var default_mask : int
var target_position : float
var is_sliding : bool = false
var is_reslotting : bool = false
var slide_delay : float
var unslot_amount : float = 0
var SPRITE_DISPLACEMENT : float = 3.0
signal unslotted
signal arrived_at_target
signal reslotted


func _ready() -> void:
	default_collision = collision_layer
	default_mask = collision_mask
	particle_material = gpu_particles_1.process_material
	gpu_particles_2.process_material = gpu_particles_1.process_material
	_setup_book()
	unslot_progress(0)

func slide_to_target_position(speed : float) -> bool:
	if speed < 0.001:
		prints(speed, " - too low value for movement speed of book")
		return false
	await get_tree().create_timer(slide_delay).timeout
	var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var dist  : float = abs(position.x - target_position)
	var time  : float = dist / speed
	tween.tween_method(_set_x_position, position.x, target_position, time)
	tween.tween_callback(arrived_at_target.emit)
	return true

func _set_x_position(val) -> void:
	position.x = val

func unslot() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_method(unslot_progress, 0.0, 1.0, unslot_time)
	tween.tween_interval(position_pause)
	tween.tween_callback(unslotted.emit)

func reslot() -> void:
	is_reslotting = true
	var tween : Tween = get_tree().create_tween()
	tween.tween_interval(position_pause)
	tween.tween_method(unslot_progress, 1.0, 0.0, unslot_time)
	tween.tween_callback(reslotted.emit)
	tween.tween_property(self, "is_reslotting", false, 0)

func has_player_collision() -> bool:
	# HACK approximate using global X position and book width
	var player : Node2D
	const PLAYER_WIDTH : float = 24
	if GlobalVars.player:
		player = GlobalVars.player
	else:
		return false
	if abs(player.global_position.x - collision_shape_2d.global_position.x) < collision_shape_2d.shape.size.x / 2.0 + PLAYER_WIDTH:
		return true
	return false
		
	

func unslot_progress(percent : float) -> void:
	sprite_2d.position.y = -tex_height/2 + hitbox_bottom - percent * SPRITE_DISPLACEMENT
	if not Engine.is_editor_hint():
		if has_collision:
			if percent < 0.01:
				if is_reslotting:
					gpu_particles_1.emitting = true
					gpu_particles_2.emitting = true
				collision_layer = 0
				collision_mask  = 0
				collision_shape_2d.debug_color = Color("0099b36b")
			else:
				collision_layer = default_collision
				collision_mask  = default_mask
				collision_shape_2d.debug_color = Color("d05b836b")
		else:
			collision_layer = 0
	modulate = slide_gradient.gradient.sample(percent)
	var desaturation : float = remap(percent, 0.0, 1.0, 0.3, 0.0)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("desaturation", desaturation)
	left_texture.scale.x = percent * 0.4
	right_texture.scale.x = percent * 0.4

func _process(_delta: float) -> void:
	_engine_process()
	pass

func _engine_process() -> void:
	if Engine.is_editor_hint():
		_setup_book()

func _setup_book() -> void:
	if texture:
		sprite_2d.texture = texture
		var size : Vector2 = texture.get_size()
		tex_width = size.x
		tex_height = size.y
		width = tex_width - hitbox_left - hitbox_right
		height = tex_height - hitbox_top - hitbox_bottom
		(collision_shape_2d.shape as RectangleShape2D).size = Vector2(
			width,
			height
		)
		
		sprite_2d.position.y = -tex_height/2 + hitbox_bottom + SPRITE_DISPLACEMENT
		sprite_2d.position.x = tex_width/2 - hitbox_left
		collision_shape_2d.position.y = -tex_height/2 + hitbox_top/2 + hitbox_bottom/2
		collision_shape_2d.position.x = tex_width/2 - hitbox_right/2 - hitbox_left/2
		
		left_texture.size.y = height
		left_texture.size.x = width
		right_texture.size = left_texture.size
		left_texture.position.y = 0
		left_texture.position.x = 0
		right_texture.position.y = collision_shape_2d.position.y * 2.0
		right_texture.position.x = collision_shape_2d.position.x * 2.0
		
		particle_material.emission_box_extents = Vector3(1, height / 2.0, 1)
		gpu_particles_1.position.x = left_texture.position.x
		gpu_particles_2.position.x = right_texture.position.x
		gpu_particles_1.position.y = collision_shape_2d.position.y
		gpu_particles_2.position.y = collision_shape_2d.position.y
