extends Node2D

func _ready() -> void:
	SignalBus.tower_ready.emit()
