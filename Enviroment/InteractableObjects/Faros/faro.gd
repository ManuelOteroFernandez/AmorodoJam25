extends BaseInteractableObject

@export var cameraShader: ColorRect
@export var faroOn: CompressedTexture2D = preload("res://Imagenes/Faros/faro1.png")
@export var faroOff: CompressedTexture2D = preload("res://Imagenes/Faros/faro1off.png")

func _ready() -> void:
	$Faro.texture = faroOff

func do_action(sender:Player):
	super.do_action(sender)
	var tween = get_tree().create_tween()
	tween.tween_property(cameraShader, "material:shader_parameter/vignette_strength", 0, 1)  
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(cameraShader, "material:shader_parameter/sepia_tone",Color(0.935, 0.906, 0.728), 1)
	tween2.tween_callback(end_action)
	
	$Faro.texture = faroOn
	$InteractionArea.queue_free()

func end_action():
	super.end_action()
