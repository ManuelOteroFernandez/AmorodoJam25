extends Node2D

func _ready() -> void:
	$SignSequence.end_sign_sequence.connect(_start_level)
	
func  _start_level():
	var player_spawner = find_level_spawn()
	Global.spawn_player(player_spawner.global_position,self)
	
func find_level_spawn() -> Node2D:
	return get_tree().get_first_node_in_group("player_spawner")
