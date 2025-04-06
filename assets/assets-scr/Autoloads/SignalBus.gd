extends Node
@warning_ignore_start("unused_signal")


# Manage current room
signal room_changed(Node2D)

# Manage player
signal player_died
signal player_respawn_requested
signal player_respawned
