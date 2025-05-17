extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var scene_manager = get_tree().current_scene as SceneManager
		if scene_manager:
			scene_manager.open_next_level()
		else:
			printerr("No se pudo encontrar el SceneManager")
