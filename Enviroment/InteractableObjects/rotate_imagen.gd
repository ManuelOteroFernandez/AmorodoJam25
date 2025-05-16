extends TextureRect

@export var rot_min = -20
@export var rot_max = 20
@export var time = 0.5

func _ready() -> void:
	rotation_degrees = rot_min
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", rot_max, time)
	tween.tween_property(self, "rotation_degrees", rot_min, time)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
