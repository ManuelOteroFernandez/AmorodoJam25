extends Control

var sm:SceneManager
func _ready() -> void:
	sm = get_tree().current_scene as SceneManager

func _on_btn_start_game_pressed() -> void:
	if sm:
		sm.open_level(0)
	else:
		printerr("MenuMain not find SceneManaer")


func _on_btn_controls_pressed() -> void:
	if sm:
		sm.open_menu(SceneManager.MENU_TYPE.CONTROLS)
	else:
		printerr("MenuMain not find SceneManaer")


func _on_btn_credits_pressed() -> void:
	if sm:
		sm.open_menu(SceneManager.MENU_TYPE.CREDITS)
	else:
		printerr("MenuMain not find SceneManaer")
