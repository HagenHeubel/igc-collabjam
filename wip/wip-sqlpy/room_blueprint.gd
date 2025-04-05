class_name TowerRoom
extends Node2D

@export var previous_room : TowerRoom
@export var next_room : TowerRoom
@export var camera_static : bool = true
@export var start_room : bool = false
@onready var camera_target: Marker2D = %CameraTarget
@onready var camera_bounds: ReferenceRect = $CameraBounds

@onready var prev_room_door: RoomDoor = $PrevRoomDoor
@onready var next_room_door: RoomDoor = $NextRoomDoor

func _ready() -> void:
	if start_room:
		SignalBus.room_changed.emit(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player : Node2D = GlobalVars.player
	var closest_door : RoomDoor = RoomDoor.get_closest_door_to_player()
	if closest_door == prev_room_door:
		SignalBus.room_changed.emit(previous_room)
	if closest_door == next_room_door:
		SignalBus.room_changed.emit(next_room)
	if not camera_static:
		adjust_camera_target()

func adjust_camera_target() -> void:
	var player : Node2D = GlobalVars.player
	camera_target.global_position = Util.clamp_point_to_rect(player.global_position, camera_bounds.get_global_rect())
