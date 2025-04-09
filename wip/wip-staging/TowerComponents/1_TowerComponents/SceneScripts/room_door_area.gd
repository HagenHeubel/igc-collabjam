class_name RoomDoorArea
extends Area2D

static var overlapped_door_areas: Array = []
var target_room: TowerRoom = null

func set_target_room(new_target: TowerRoom) -> void:
	target_room = new_target

func _process(_delta: float) -> void:
	# Update overlapped list.
	var bodies: Array = get_overlapping_bodies()
	var player: Node2D = GlobalVars.player
	var player_area: Area2D = GlobalVars.player_area
	if (player in bodies) or player_area.overlaps_area(self):
		if self not in overlapped_door_areas:
			overlapped_door_areas.append(self)
	else:
		if self in overlapped_door_areas:
			overlapped_door_areas.erase(self)
	
	if get_door_area_closest_to_player() == self and target_room and (target_room != GlobalVars.current_room):
		prints("Room transition triggered from", GlobalVars.current_room.name, "to", target_room.name)
		SignalBus.room_changed.emit(target_room)

static func get_door_area_closest_to_player() -> RoomDoorArea:
	var closest: RoomDoorArea = null
	var closest_distance: float = INF
	for door in overlapped_door_areas:
		var dist: float = door.get_manhattan_distance_to_player() 
		if dist < closest_distance:
			closest_distance = dist
			closest = door
	return closest

func get_manhattan_distance_to_player() -> float:
	var player: Node2D = GlobalVars.player
	if not player:
		print("Player not registered in GlobalVars. Returning -1.")
		return -1
	return Util.manhattan_distance(global_position, player.global_position)
