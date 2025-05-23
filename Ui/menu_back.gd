extends Control


func back():
	var sm = get_tree().current_scene as SceneManager
	if sm:
		sm.close_menu()
	else:
		printerr("Menu not find SceneManager")
		
func set_default_focus():
	$BtnBackMainMenu.grab_focus()
