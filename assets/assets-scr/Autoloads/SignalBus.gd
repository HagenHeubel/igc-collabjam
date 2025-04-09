extends Node
@warning_ignore_start("unused_signal")


# Manage Rooms and level scene
signal room_changed(Node2D)
signal register_room(TowerRoom)
signal tower_ready # Emitted after all nodes in the tower have been initialized

# Manage player
signal player_died
signal player_respawn_requested
signal player_respawned
