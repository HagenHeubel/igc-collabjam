extends Level

@onready var room_door: RoomDoor = $GameSpace/Floor1/RoomDoor

func _ready() -> void:
	super()
	#HACK Snaps the camera to spawn room
	room_door.orange_area.set_target_room(room_door.orange_room)
	SignalBus.room_changed.emit(room_door.orange_area.target_room)
