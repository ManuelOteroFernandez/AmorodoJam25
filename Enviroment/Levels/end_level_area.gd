extends Area2D





func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var sm:SceneManager = get_tree().current_scene as SceneManager
		if sm:
			sm.open_next_level()
