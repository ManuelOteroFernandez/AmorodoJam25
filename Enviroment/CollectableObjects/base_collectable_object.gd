extends Area2D

@export var value: int = 1
@export var type: Collectable.COLLECTABLE_TYPE = Collectable.COLLECTABLE_TYPE.BREZO


func _ready() -> void:
	Collectable.register_collectable_value(type,value)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	Collectable.add_collectable_object(type,value)
	queue_free()
