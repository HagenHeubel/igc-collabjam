class_name RoomCamera2D
extends Camera2D

@export_range(0.1, 30.0, 0.1) var convergence_speed : float = 20.0
@export var is_in_other_world : bool = false
var prev_position : Vector2

func _ready() -> void:
	GlobalVars.camera = self
	prev_position = global_position
	if not is_in_other_world:
		SignalBus.prev_camera_position_updated.connect(_on_prev_position_updated)

func _process(delta: float) -> void:
	if is_in_other_world:
		var current_room : TowerRoom = GlobalVars.current_room
		if current_room != null:
			global_position = Util.delta_lerp_vec2(global_position, current_room.camera_target.global_position, convergence_speed, delta)
			SignalBus.prev_camera_position_updated.emit(global_position)

func _on_prev_position_updated(pos : Vector2) -> void:
	global_position = pos
