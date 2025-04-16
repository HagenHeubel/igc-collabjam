extends BreakAbleObject
class_name PhysicalBook


@onready var accent: Sprite2D = $Accent
@export var color: Color



func _ready() -> void:
	sprite.set_modulate(color)
	super()
	
func _on_break_triggered(_break_velocity : Vector2) -> void:
	accent.hide()
	super(_break_velocity)


func take_damage(amount: int) -> void:
	super(amount)
