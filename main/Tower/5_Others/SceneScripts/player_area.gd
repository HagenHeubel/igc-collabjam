class_name PlayerArea
extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.player_area = self
