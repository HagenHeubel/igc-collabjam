extends Area2D

@onready var object_spawner: Node2D = $"../ObjectSpawner"
@onready var point_light_2d: PointLight2D = $"../PointLight2D"
@onready var cauldron: RigidBody2D = $".."

var hit : bool = false
func _on_body_entered(body: Node2D) -> void:
	if not hit:
		if body == GlobalVars.player:
			hit = true
			sequence()

func sequence() -> void:
	object_spawner.spawning = true
	cauldron.apply_torque_impulse(-400)
	await get_tree().create_timer(2).timeout
	point_light_2d.queue_free()
	object_spawner.spawning = false
