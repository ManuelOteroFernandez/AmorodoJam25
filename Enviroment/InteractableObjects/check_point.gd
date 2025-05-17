extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var sm:SceneManager = get_tree().current_scene as SceneManager
		var index = sm.current_level_index if sm else 0
		Global.set_last_checkpoint_data(index, global_position)
