extends Level

func _ready() -> void:
	super()
	SignalBus.tower_ready.emit()
