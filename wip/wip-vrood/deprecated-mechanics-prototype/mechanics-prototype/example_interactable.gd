extends StaticBody2D
# example_interactable


func do_the_interaction() -> void:
	prints("I've been interacted with at", global_position)

func _on_interactable_component_interacted() -> void:
	do_the_interaction()
