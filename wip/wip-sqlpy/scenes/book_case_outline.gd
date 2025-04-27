@tool
extends NinePatchRect

@onready var book_case: Control = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = Vector2.ZERO + Vector2.UP * 10 + Vector2.LEFT * 6
	size = book_case.size * 1.0/0.13 + Vector2.DOWN * 100.0 + Vector2.RIGHT * 120
