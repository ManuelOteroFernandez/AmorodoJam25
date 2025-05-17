extends CanvasLayer

signal end_sign_sequence

@export var elements:Array[SignSequenceData]
@export var wait_time: float

var current_index = 0

func _ready() -> void:
	if elements.size() >= 1:
		_set_data()
		$Control/Timer.wait_time = wait_time
		$Control/Timer.timeout.connect(_complete_sequence)
		$Control/Timer.start()
	else: 
		_complete_sequence()
		
func _hide_data():
	current_index += 1
	var tween = get_tree().create_tween()
	tween.finished.connect(_next_data)
	tween.tween_property($Control/RichTextLabel,"modulate", Color.TRANSPARENT,0.5)


func _complete_sequence():
	if elements.size() > current_index + 1:
		_hide_data()
	else:
		end_sign_sequence.emit()
		await get_tree().create_tween().tween_property($Control,"modulate",Color.TRANSPARENT,1).finished
		queue_free()
		
func _next_data():
	_set_data()
	var tween = get_tree().create_tween()
	tween.tween_property($Control/RichTextLabel,"modulate", Color.WHITE,0.5)
	$Control/Timer.start()
	
	
func _set_data():
	var data =  elements.get(current_index)
	$Control/RichTextLabel.text = data.text
	$Control/ColorRect.color = data.background_color
	
