class_name RoomDoor
extends Area2D

# Holds a list of RoomDoor instances that the player is currently overlapping.
static var player_overlapped_room_door_list: Array = []

func _process(_delta: float) -> void:
	# Get all bodies overlapping this Area2D.
	var overlapping_bodies : Array[Node2D] = get_overlapping_bodies()
	var player : Node2D = GlobalVars.player
	if player in overlapping_bodies:
		if self not in player_overlapped_room_door_list:
			player_overlapped_room_door_list.append(self)
			prints(self, "added to list")
	# Otherwise, if the player is not overlapping, remove self from the list.
	else:
		if self in player_overlapped_room_door_list:
			player_overlapped_room_door_list.erase(self)
			prints(self, "removed from list")
	if not player_overlapped_room_door_list.is_empty():
		print(get_closest_door_to_player())

static func get_closest_door_to_player() -> RoomDoor:
	var closest_door : RoomDoor = null
	var closest_distance : float = 1000000
	for door : RoomDoor in player_overlapped_room_door_list:
		var dist : float = door.get_manhatten_distance_to_player() 
		if dist < closest_distance:
			closest_door = door
			closest_distance = dist
	return closest_door

func get_manhatten_distance_to_player() -> float:
	var player : Node2D = GlobalVars.player
	if not player:
		return -1
	return Util.manhatten_distance(global_position, player.global_position)
	
