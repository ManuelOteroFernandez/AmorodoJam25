class_name Cartel extends Control

@export var scale_max = Vector2(1,1)
@export var scale_min = Vector2(0,0)
@export var time = 0.5

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = scale_min
		
func show_cartel():
	tween = create_tween()
	tween.tween_property(self, "scale", scale_max, time)
	tween.play()
	
func hide_cartel():
	tween = create_tween()
	tween.tween_property(self, "scale", scale_min, time)
	tween.play()
