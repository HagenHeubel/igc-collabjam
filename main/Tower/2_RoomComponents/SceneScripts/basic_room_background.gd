@tool
extends Control

@export var background_color : Color: set = _set_color
@export var room_gradient : Texture2D: set = _set_gradient
@onready var background_color_rect: ColorRect = $BackgroundColor
@onready var gradient: TextureRect = $Gradient

func _set_color(value : Color) -> void:
	if !background_color_rect: return
	background_color_rect.color = value
	background_color = value

func _set_gradient(value : Texture2D) -> void:
	if !gradient: return
	gradient.texture = value
	room_gradient = value
