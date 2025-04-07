class_name RespawnRoom
extends TowerRoom


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	SignalBus.player_respawn_requested.connect(_on_player_respawn_requested)

func _on_player_respawn_requested() -> void:
	SignalBus.player_respawned.emit()
