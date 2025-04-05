extends Camera2D

func _process(delta: float) -> void:
	var current_room : TowerRoom = GlobalVars.current_room
	if current_room != null:
		global_position = Util.delta_lerp_vec2(global_position, current_room.camera_target.global_position, 20, delta)
