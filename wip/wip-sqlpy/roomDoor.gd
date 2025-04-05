class_name RoomDoor
extends Area2D

@export var use_y_direction_to_player : bool = false

# Holds a list of RoomDoor instances that the player is currently overlapping.
static var player_overlapped_room_door_list: Array = []


func _process(delta: float) -> void:
	# Get all bodies overlapping this Area2D.
	var overlapping_bodies : Array[Node2D] = get_overlapping_bodies()
	var player : Node2D = GlobalVars.player
	if player in overlapping_bodies:
		if self not in player_overlapped_room_door_list:
			player_overlapped_room_door_list.append(self)
	# Otherwise, if the player is not overlapping, remove self from the list.
	else:
		if self in player_overlapped_room_door_list:
			player_overlapped_room_door_list.erase(self)

static func get_closest_door_to_player() -> RoomDoor:
	var closest_door : RoomDoor = null
	var closest_distance : float = 100000
	for door : RoomDoor in player_overlapped_room_door_list:
		var dist : float = door.get_distance_to_player() 
		if dist < closest_distance:
			closest_door = door
			closest_distance = dist
	if closest_distance == -1:
		return null
	return closest_door

func get_distance_to_player() -> float:
	var player : Node2D = GlobalVars.player
	if not player:
		return -1
	if use_y_direction_to_player:
		return abs(player.global_position.y - global_position.y)
	else:
		return abs(player.global_position.x - global_position.x)
	
