class_name TransitionManagerClass extends Control

signal mid_transition_signal
signal end_transition_signal

enum Transitions { None, FADE }

const TRANSITION_DICT = {
	Transitions.FADE: ["Fade_in","Fade_out"],
}

var current_transition: Transitions = Transitions.None

func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(self._animation_finish)

func is_in_transition() -> bool:
	return current_transition != Transitions.None

func _animation_finish(_anim_name:StringName):
	if current_transition == Transitions.None:
		end_transition_signal.emit()
	else:
		mid_transition_signal.emit()

func start_transition(transition:Transitions = Transitions.FADE) -> bool:
	if is_in_transition() or transition == Transitions.None:
		return false
		
	current_transition = transition
	$AnimationPlayer.play(TRANSITION_DICT[current_transition][0])
	
	return true

func end_transition(transition:Transitions = Transitions.None) -> bool:
	if transition != Transitions.None:
		current_transition = transition
		
	if not is_in_transition():
		return false
		
	$AnimationPlayer.play(TRANSITION_DICT[current_transition][1])
	current_transition = Transitions.None
	
	return true
