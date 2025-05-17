extends Node

signal player_spawn_signal

var lastCheckpointData = {
	"levelIndex": null,
	"position": Vector2.ZERO
}
var player:Player
var playerTscn : PackedScene = ResourceLoader.load("res://Character/character.tscn")
var sm:SceneManager

func _ready() -> void:
	sm = get_tree().current_scene as SceneManager

func set_last_checkpoint_data(levelIndex, position):
	lastCheckpointData["levelIndex"] = levelIndex
	lastCheckpointData["position"] = position
	
func restart_in_checkpoint():
	if sm:
		sm.tsm.start_transition()
		await sm.tsm.mid_transition_signal
		
	player.global_position = lastCheckpointData.get("position", player.global_position)
	
	if sm:
		sm.tsm.end_transition()

func spawn_player(spawn_positon: Vector2, parent:Node):
	player = playerTscn.instantiate()
	parent.add_child(player)
	player.global_position = spawn_positon
	
	set_last_checkpoint_data(sm.current_level_index if sm else 0, spawn_positon)
	
	player.take_damage_signal.connect(restart_in_checkpoint)
	
	player_spawn_signal.emit()
