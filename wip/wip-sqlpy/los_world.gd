extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.line_of_sight_world = self
	get_tree().root.get_viewport().size_changed.connect(_on_screen_size_changed)
	_on_screen_size_changed()

func _on_screen_size_changed() -> void:
	size = get_tree().root.get_viewport().get_visible_rect().size
