extends Resource
class_name SceneSequenceData

@export var dialog_list: Array[String]
@export var background_color: Color = Color.BLACK
@export var background_image: Texture2D

var index = 0

func get_next_dialog() -> String:
	var ret = dialog_list[index]
	index += 1
	
	return ret

func has_more_dialogs() -> bool:
	return dialog_list.size() > index
