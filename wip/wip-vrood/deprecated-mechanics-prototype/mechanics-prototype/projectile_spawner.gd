extends Marker2D
class_name ProjectileSpawner

@export var world_node: Node2D
@export var projectile_scene: PackedScene
@export var speed: float = 200.0
@export var damage: int = 1
@export var lifetime: float = 5.0

func spawn_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.position = global_position
	projectile.velocity = Vector2.RIGHT.rotated(global_rotation) * speed
	projectile.damage = damage
	projectile.lifetime = lifetime
	
	if world_node:
		world_node.add_child(projectile)
	else:
		get_parent().add_child(projectile)
	
