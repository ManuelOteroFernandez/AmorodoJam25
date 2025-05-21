extends Area2D

signal player_in_area
signal player_out_area

var player:Player

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	player = body as Player
	player.can_interact = true
	player.do_action_signal.connect(get_parent().do_action)
	player_in_area.emit()

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	player = body as Player
	player.can_interact = false
	player.do_action_signal.disconnect(get_parent().do_action)
	player_out_area.emit()
