@tool
extends Control

@export var background_modulate : Color = Color("9a92af"):
	set(val):
		background_modulate = val
		in_background_layer = in_background_layer
@export_range(0.0, 1.0, 0.01) var background_desaturate : float = 0.5:
	set(val):
		background_desaturate = val
		in_background_layer = in_background_layer
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var light_occluder_rect: LightOccluderRect = $StaticBody2D/LightOccluderRect

@export var in_background_layer : bool = false:
	set(val):
		in_background_layer = val
		if is_node_ready():
			if val:
				modulate = background_modulate
				static_body_2d.collision_layer = 0
				static_body_2d.collision_mask  = 0
				light_occluder_rect.occluder_light_mask = 0
				(material as ShaderMaterial).set_shader_parameter("desaturation", background_desaturate)
			else:
				modulate = Color.WHITE
				static_body_2d.collision_layer = collision_layer
				static_body_2d.collision_mask  = collision_mask
				light_occluder_rect.occluder_light_mask = 1
				(material as ShaderMaterial).set_shader_parameter("desaturation", 0.0)

@export_flags_2d_physics var collision_layer = 1
@export_flags_2d_physics var collision_mask  = 4

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	SignalBus.tower_ready.connect(_on_tower_ready)

func _on_tower_ready() -> void:
	in_background_layer = in_background_layer
