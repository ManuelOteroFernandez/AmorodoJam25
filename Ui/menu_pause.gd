extends Control


var tsm: TransitionManagerClass
var sm :SceneManager

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var parent = get_tree().current_scene
	if parent is SceneManager:
		sm = parent as SceneManager
		sm.pause_signal.connect(on_pause)
		tsm = sm.get_transitionManager()
	else:
		printerr("Not find SceneManager")
	
	
	
func on_pause():
	if sm.is_open_any_menu():
		visible = false
		return 
		
	if not tsm:
		tsm = sm.get_transitionManager()
		
	if tsm.is_in_transition():
		get_tree().paused = true
		return
		
	if not get_tree().paused:
		visible = false
	else:
		tsm.mid_transition_signal.connect(self._on_mid_transition)
		tsm.start_transition(TransitionManagerClass.Transitions.FADE)

func _on_mid_transition():
	tsm.mid_transition_signal.disconnect(self._on_mid_transition)
	visible = true
	tsm.end_transition()
	

func _on_btn_continue_pressed() -> void:
	sm.pause(false)


func _on_btn_back_main_menu_button_up() -> void:
	sm.open_main_menu()
