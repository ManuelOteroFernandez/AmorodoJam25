extends Node2D

@export var distance:float
@export var time:float

func _ready() -> void:
	$AnimatedSprite2D.flip_h = distance > 0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var goal = global_position.x + distance
		var final_val = Vector2(goal,global_position.y)
		$AnimatedSprite2D.play("default")
		$AudioStreamPlayer2D.play()
		await get_tree().create_tween().tween_property(self,"global_position",final_val, time).finished
		queue_free()
