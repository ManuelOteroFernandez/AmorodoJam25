extends Area2D

@export var value: int = 1
@export var type: Collectable.COLLECTABLE_TYPE = Collectable.COLLECTABLE_TYPE.BREZO

var is_colleted:bool = false

func _ready() -> void:
	Collectable.register_collectable_value(type,value)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or is_colleted:
		return
		
	is_colleted = true
	$AudioStreamPlayer2D.play()
	Collectable.add_collectable_object(type,value)
	create_tween().tween_property(self,"modulate",Color.TRANSPARENT,3)
	await $AudioStreamPlayer2D.finished
	queue_free()
