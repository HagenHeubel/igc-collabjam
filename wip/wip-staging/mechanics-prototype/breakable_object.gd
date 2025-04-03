extends RigidBody2D


signal harmed()
signal healed()
signal died()

@export var HEALTH_MAX: int = 9
var health = HEALTH_MAX


func take_damage(amount: int) -> void:
	if amount <= 0: 
		printerr("You can't take negative damage")
	health -= amount
	harmed.emit()
	if health <= 0:
		health = 0
		die()
	prints(self.name, health)
	
func heal(amount: int) -> void:
	if amount <= 0:
		printerr("You can't heal a negative amount")
	health += amount
	healed.emit()
	if health >= HEALTH_MAX:
		health = HEALTH_MAX
	prints(self.name, health)

func die() -> void:
	died.emit()
	call_deferred("queue_free")
