extends Node

var lastCheckpointData = {
	"levelPath": null,
	"position": Vector2.ZERO
}
var player:Player
var playerTscn : PackedScene = ResourceLoader.load("res://Character/character.tscn")

func set_last_checkpoint_data(levelPath, position):
	lastCheckpointData["levelPath"] = levelPath
	lastCheckpointData["position"] = position
	
func restart_in_checkpoint():
	player.positon = lastCheckpointData.get("positon", player.position)

func spawn_player(spawn_positon: Vector2):
	player = playerTscn.instantiate()
	add_child(player)
	player.global_position = spawn_positon
	
func find_level_spawn() -> Node2D:
	return get_tree().get_first_node_in_group("player_spawner")

func start_game():
	var player_spawner = find_level_spawn()
	spawn_player(player_spawner.global_position)
