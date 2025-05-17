extends CanvasLayer

var sm:SceneManager

func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		queue_free()
	else:
		var parent = get_tree().current_scene
		if parent is SceneManager:
			sm = (parent as SceneManager)
			sm.open_level_end_signal.connect(_change_visibility)
			#sm.pause_signal.connect(_change_visibility)
	
func _change_visibility():
	var is_open_any_menu = sm.is_open_any_menu() if sm else true
	visible = not get_tree().paused and not is_open_any_menu
