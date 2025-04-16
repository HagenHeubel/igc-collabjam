extends Node
# Global Variable Bus

var player : Node2D
var player_area : Area2D
var player_light : PointLight2D
var camera : Camera2D
var current_room : TowerRoom

# In the player script, call `GlobalVars.set_global_player(self)`
func set_global_player(actor: Node) -> void:
	player = actor


func get_global_player() -> Node:
	return player
