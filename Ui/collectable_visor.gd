extends TextureRect

@export var collectable_type:Collectable.COLLECTABLE_TYPE
@export var textureCol:Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = textureCol
	_setup()


func _setup() -> void:
	$RichTextLabel.text = str(Collectable.get_collectable_value(collectable_type))
	$RichTextLabel3.text = str(Collectable.get_max_collectable_value(collectable_type))


func _on_menu_pause_visibility_changed() -> void:
	_setup()
