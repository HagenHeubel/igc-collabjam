extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.room_changed.connect(_on_room_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_room_changed(target_room : TowerRoom) -> void:
	GlobalVars.current_room = target_room
