
class_name HoverEffectVFX extends Node2D

@export_group("Hover Effect", "hover_effect") # 1st argument names the group, second removes prefixes in editor
@export_custom(PROPERTY_HINT_NONE, "suffix:sec") var hover_effect_delay: float
@export var hover_effect_intensity: float
@export var hover_effect_target_node: Node2D
# Called when the node enters the scene tree for the first time.
func _ready()->void:
	hover_effect_up()
func hover_effect_up()->void:
	var tween: Tween = create_tween() #Standard process for creating a temp tween
	var tween_rate: float = hover_effect_delay
	var tween_distance: float = hover_effect_intensity
	var tween_target: Node2D = hover_effect_target_node
	tween.tween_property(tween_target, "position", tween_target.position + Vector2(0,-tween_distance), tween_rate).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(hover_effect_down)
func hover_effect_down() -> void:
	var tween: Tween = create_tween() #Standard process for creating a temp tween
	var tween_rate: float = hover_effect_delay
	var tween_distance: float = hover_effect_intensity
	var tween_target: Node2D = hover_effect_target_node
	tween.tween_property(tween_target, "position", tween_target.position + Vector2(0,tween_distance), tween_rate).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(hover_effect_up)
