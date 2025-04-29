@tool
extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_parent().move_child(self, get_parent().get_child_count())
