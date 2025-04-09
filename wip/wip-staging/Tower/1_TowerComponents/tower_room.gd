class_name TowerRoom
extends Node2D

@export var camera_static: bool = true
@export var start_room: bool = false
@onready var camera_target: Marker2D = $CameraTarget
@onready var camera_bounds: ReferenceRect = $CameraBounds
@onready var room_content: Node2D = $RoomContent

var adjacent_rooms: Array = []

func _ready() -> void:
	SignalBus.register_room.emit(self)
	if start_room:
		SignalBus.room_changed.emit(self)

func _process(_delta: float) -> void:
	_adjust_camera_target()

func _adjust_camera_target() -> void:
	if not camera_static:
		camera_target.global_position = Util.clamp_point_to_rect(GlobalVars.player.global_position, camera_bounds.get_global_rect())

func enable() -> void:
	room_content.show()
	room_content.set_process(true)
	room_content.set_physics_process(true)
	room_content.set_process_input(true)

func disable() -> void:
	room_content.hide()
	room_content.set_process(false)
	room_content.set_physics_process(false)
	room_content.set_process_input(false)
