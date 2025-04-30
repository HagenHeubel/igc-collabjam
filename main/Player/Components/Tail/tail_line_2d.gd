extends Line2D

@onready var static_body_2d: StaticBody2D = $"../StaticBody2D"
@onready var tail_segment: RigidBody2D = $"../Tail segment"
@onready var tail_segment_2: RigidBody2D = $"../Tail segment2"
@onready var tail_segment_3: RigidBody2D = $"../Tail segment3"
@onready var tail_segment_4: RigidBody2D = $"../Tail segment4"
@onready var tail_tip: Node2D = %TailTip
@onready var tail: Node2D = $".."

func _process(_delta: float) -> void:
	rotation = -tail.rotation
	var p0 : Vector2 = static_body_2d.global_position - tail.global_position
	var p1 : Vector2 = tail_segment.global_position - tail.global_position
	var p2 : Vector2 = tail_segment_2.global_position - tail.global_position
	var p3 : Vector2 = tail_segment_3.global_position - tail.global_position
	var p4 : Vector2 = tail_segment_4.global_position - tail.global_position
	var p5 : Vector2 = tail_tip.global_position - tail.global_position
	var pts : Array[Vector2] = [p0, p0, p1, p2, p3, p4, p5, p5]
	points = Util.b_spline_from_points(pts, 20, 3)
