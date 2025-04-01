
class_name ScaleSpriteComponent # courtesy of Heartbeast @Youtube.
extends Node
@export var sprite: Node2D ## Works with AnimatedSprite2D & Sprite2D; other Node2D haven't been tested
@export var scale_amount: Vector2 = Vector2(1.5, 1.5)
@export_custom(PROPERTY_HINT_NONE, "suffix: sec") var scale_duration: float = 0.4 ## in seconds; time it takes to complet the tween
@export var scale_ease_in: float = 0.1
@export var scale_ease_out: float = 0.9
@onready var initial_scale: Vector2 = sprite.scale

func tween_scale()->void:
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT) # First we create the tween and set its transition type and easing type
	tween.tween_property(sprite, "scale", scale_amount, scale_duration * scale_ease_in).from_current() # Next we scale the sprite from its current scale to the scale_ease_in amount (in currently 1/10th of the scale duration)
	tween.tween_property(sprite, "scale", initial_scale, scale_duration * scale_ease_out).from(scale_amount) 	# Finally we scale back to the initial value for the other scale_ease_out, default 9/10ths, of the scale duration

func set_target(new: Node2D) ->void:
	if new is not Node2D:
		return
	sprite = new
	initial_scale = sprite.scale
