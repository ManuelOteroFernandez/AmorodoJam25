extends CanvasLayer
class_name StoryScene

@export var time_inner_dialog = 5
@export var sceneData:Array[SceneSequenceData]

var sm: SceneManager
var index = 0
var is_change_dialog = false

func start_sequence() -> void:
	sm = get_tree().current_scene as SceneManager
	if sceneData.size() > 0 and sceneData[index].has_more_dialogs():
		_setup_scene_data()
		return
		
	sm.open_next_level()

func _next_dialog():
	is_change_dialog = true
	if sceneData[index].has_more_dialogs():
		await create_tween().tween_property($RichTextLabel,"modulate",Color.TRANSPARENT,1).finished
		$RichTextLabel.text = sceneData[index].get_next_dialog()
		create_tween().tween_property($RichTextLabel,"modulate",Color.WHITE,1)
	elif sceneData.size() > index +1:
		index += 1
		sm.tsm.start_transition()
		await sm.tsm.mid_transition_signal
		_setup_scene_data()
		sm.tsm.end_transition()
	else:
		sm.open_next_level()
	
	is_change_dialog = false

func _setup_scene_data():
	$ColorRect.color = sceneData[index].background_color
	if sceneData[index].background_image:
		$TextureRect.visible = true
		$TextureRect.texture = sceneData[index].background_image
	else:
		$TextureRect.visible = false
	$RichTextLabel.text = sceneData[index].get_next_dialog()

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("interact") and not is_change_dialog: 
		_next_dialog()
