extends Area2D
class_name InteractableComponent

signal interacted()

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_layer_value(4, true)
	collision_mask = 0


func interact_with() -> void:
	interacted.emit()
