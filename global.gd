extends Node

signal player_spawn_signal

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

func spawn_player(spawn_positon: Vector2, parent:Node):
	player = playerTscn.instantiate()
	parent.add_child(player)
	player.global_position = spawn_positon
	player_spawn_signal.emit()
