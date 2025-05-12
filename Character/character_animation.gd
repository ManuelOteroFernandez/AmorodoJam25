extends AnimatedSprite2D


@onready var parent:Player = get_parent()

func _ready():
	play("idle")

func _process(_delta: float) -> void:
	if not parent:
		printerr("Character animated sprite cannot find parent")
		return
	
	match parent.current_state:
		Player.STATES.IDLE:
			play("idle")
		Player.STATES.RUNNING:
			play("run")
		Player.STATES.JUMPING:
			play("jump")

	if parent.velocity.x != 0:
		flip_h = parent.velocity.x > 0
