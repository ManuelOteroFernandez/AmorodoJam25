extends Area2D

func _ready() -> void:
	body_entered.connect(_do_damage)
	
func _do_damage(body: Node2D) -> void:
	if body.is_in_group("player") and body is Player:
		(body as Player).recieve_damage()
