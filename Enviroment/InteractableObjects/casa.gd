extends BaseInteractableObject


@export var texture: Texture2D
@export var positve_text: String
@export var negative_text: String

var used = false

func _ready() -> void:
	$CasaSprite.texture = texture
	Collectable.register_collectable_value(Collectable.COLLECTABLE_TYPE.CASA)

func do_action(sender:Player):
	super.do_action(sender)
	if Collectable.use_collectable_object(Collectable.COLLECTABLE_TYPE.CASA):
		Collectable.add_collectable_object(Collectable.COLLECTABLE_TYPE.CASA)
		used = true
		$InteractableButons.queue_free()
		$ResponseInteraction.set_text(positve_text)
		$InteractionArea.player_in_area.connect($ResponseInteraction.show_cartel)
	else:
		$ResponseInteraction.set_text(negative_text)
		
	$ResponseInteraction.show_cartel()
	end_action()

func end_action():
	super.end_action()
