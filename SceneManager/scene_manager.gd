class_name SceneManager extends Node

@export var transition = TransitionManagerClass.Transitions.FADE

@onready var menu_main = preload("res://Ui/menu_main.tscn")
@onready var menu_credits = preload("res://Ui/menu_credits.tscn")
@onready var menu_controls = preload("res://Ui/menu_controls.tscn")
@onready var tsm : TransitionManagerClass = $UI/TransitionManager

signal open_level_end_signal
signal pause_signal

enum MENU_TYPE { CREDITS, CONTROLS }
enum Transition_to { None, MainMenu, Level, Credits, Controls, CloseMenu }

var story_index = 1
var story01: Array[NodePath] = [
	"res://Story/story_scene_01.tres",
	"res://Story/story_scene_02.tres", 
	"res://Story/story_scene_03.tres",
	"res://Story/story_scene_04.tres",
	"res://Story/story_scene_05.tres"
]
var story02: Array[NodePath] = [
	"res://Story/story_scene_07.tres",
	"res://Story/story_scene_08.tres"
]

var next_scene = null
var current_transition = Transition_to.None
var current_level_index = 0

const level_list = [
	"res://Story/story.tscn",
	"res://Enviroment/Levels/Level01.tscn",
	"res://Story/story.tscn"
]

func _ready() -> void:
	tsm.mid_transition_signal.connect(self._on_mid_transition)
	tsm.mid_transition_signal.connect(self._on_end_transition)
	
	tsm.end_transition(transition)
	current_transition = Transition_to.MainMenu
	_on_mid_open_main_menu()
	

func open_level(level_index:int):
	
	if level_index < len(level_list):
		next_scene = level_list[level_index]
		current_level_index = level_index
		current_transition = Transition_to.Level
		pause(true)
		tsm.start_transition(transition)
	else:
		current_level_index = 0
		open_main_menu()

func open_next_level():
	open_level(current_level_index+1)

func open_main_menu():
	current_transition = Transition_to.MainMenu
	pause(true)
	tsm.start_transition(transition)
	story_index = 1
	
func _on_mid_open_main_menu():	
	$CurrentSceneStack.get_child(0).queue_free()
	var instance = menu_main.instantiate()
	$CurrentSceneStack.add_child(instance)
	instance.set_default_focus()
	
func open_menu(menu:MENU_TYPE):
	var currect_scene_path = $CurrentSceneStack.get_child(0).scene_file_path
	if currect_scene_path == menu_main.resource_path:
		match menu:
			MENU_TYPE.CREDITS:
				current_transition = Transition_to.Credits
			MENU_TYPE.CONTROLS:
				current_transition = Transition_to.Controls
				
		tsm.start_transition(transition)
		
func  _on_mid_open_menu():
	var node = null
	match current_transition:
		Transition_to.Credits:
			node = menu_credits.instantiate()
		Transition_to.Controls:
			node = menu_controls.instantiate()
		
	if node:
		$CurrentSceneStack.add_child(node)
		if node.has_method("set_default_focus"):
			node.set_default_focus()
	
func close_menu():
	current_transition = Transition_to.CloseMenu
	tsm.start_transition(transition)
	
func _on_mid_transition():
	if current_transition != Transition_to.None:
		tsm.end_transition()
	
	if current_transition == Transition_to.Level:
		$CurrentSceneStack.get_child(0).queue_free()
		var scene_node:Node = load(next_scene).instantiate()
		$CurrentSceneStack.add_child(scene_node)
		$CurrentSceneStack.move_child(scene_node,0)
		
		if scene_node is StoryScene:
			if story_index == 1:
				scene_node.sceneData = _load_story_data(story01)
				story_index = 2
			else:
				scene_node.sceneData = _load_story_data(story02)
				story_index = 1
			scene_node.start_sequence()
		
	elif current_transition == Transition_to.MainMenu:
		_on_mid_open_main_menu()
	elif current_transition in [Transition_to.Credits, Transition_to.Controls]:
		_on_mid_open_menu()
	elif current_transition == Transition_to.CloseMenu and $CurrentSceneStack.get_child_count() > 1:
		var node:Control = $CurrentSceneStack.get_children().back()
		node.reparent(self)
		node.queue_free()
		
		var current_menu = $CurrentSceneStack.get_children().back()
		if current_menu != null and current_menu.has_method("set_default_focus"):
			current_menu.set_default_focus()

func _load_story_data(data_path_list: Array[NodePath]):
	var data: Array[SceneSequenceData]
	
	for scene_squence_data:NodePath in data_path_list:
		data.append(load(scene_squence_data))
		
	return data

func _on_end_transition():
	if current_transition != Transition_to.None:
		next_scene = null
		pause(false)
		open_level_end_signal.emit()
		current_transition = Transition_to.None
		
		
func is_open_any_menu():
	return (current_transition != Transition_to.Level and \
	$CurrentSceneStack.get_children().back().is_in_group("menu")) or \
	current_transition in [Transition_to.MainMenu, Transition_to.Credits, Transition_to.Controls, Transition_to.CloseMenu]
	

func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("pause"):
		if not is_open_any_menu():
			pause(not get_tree().paused)
		
func pause(new_value:bool = false):
	get_tree().paused = new_value
	pause_signal.emit()
	
func get_transitionManager() -> TransitionManagerClass:
	return tsm
