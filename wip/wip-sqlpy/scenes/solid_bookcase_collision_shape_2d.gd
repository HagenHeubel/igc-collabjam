@tool
extends CollisionShape2D

@onready var solid_book_case: Control = $"../.."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	(shape as RectangleShape2D).size = solid_book_case.size
	position = shape.size / 2.0
