extends Area2D
class_name Projectile

# Default Values, these will be overwritten by the projectile spawner
var velocity := Vector2.ZERO
var damage: int = 1
var lifetime: float = 5.0


func _ready() -> void:
	var life_timer = Timer.new()
	life_timer.wait_time = lifetime
	life_timer.one_shot = true
	life_timer.connect("timeout", die)
	connect("body_entered", _on_body_entered)
	
func _physics_process(delta: float) -> void:
	position += velocity * delta



func die() -> void:
	queue_free()

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		die()
