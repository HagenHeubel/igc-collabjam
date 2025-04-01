
class_name Spawner2D
extends Node2D

@export var scene: PackedScene ## The Scene we'd like to spawn

## Spawn an instance of the scene at a specific global position on a parent
## By default the parent is the current "main" scene , but you can pass in
## an alternative parent if you so choose.
func spawn(global_spawn_position: Vector2 = global_position, parent: Node = get_tree().current_scene) -> Node:
	assert(scene is PackedScene, "Error: The scene export was never set on this spawner component.")
	## Instance the scene
	var instance = scene.instantiate()
	parent.add_child(instance)
	instance.global_position = global_spawn_position # This must be done after adding it as a child

	# Return the instance in case we want to perform any other operations
	# on it after instancing it.
	return instance
