extends Node
# Global Variable Bus

var player
var current_room : TowerRoom
# In the player script, call `GlobalVars.set_global_player(self)`
func set_global_player(actor: Node) -> void:
	player = actor


func get_global_player() -> Node:
	return player
