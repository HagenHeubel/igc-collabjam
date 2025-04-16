extends BreakAbleObject
class_name PotionBottle

@export var is_full: bool = true

@onready var full: Sprite2D = $Full
@onready var empty: Sprite2D = $Empty


func _ready() -> void:
	if is_full:
		full.show()
		sprite = full
		empty.hide()
	else:
		full.hide()
		sprite = empty
		empty.show()
	super()

func _on_break_triggered(_break_velocity : Vector2) -> void:
	## Make sure that the correct sprite is being passed
	if is_full:
		sprite = full
	else:
		sprite = empty
	
	super(_break_velocity)

func take_damage(amount: int) -> void:
	super(amount)
