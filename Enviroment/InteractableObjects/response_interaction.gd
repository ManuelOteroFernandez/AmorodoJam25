extends Control



func show_cartel():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1)
	tween.play()
	get_tree().create_timer(10).timeout.connect(hide_cartel)
	
func hide_cartel():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	tween.play()
	
func set_text(text:String):
	$RichTextLabel.text = text
