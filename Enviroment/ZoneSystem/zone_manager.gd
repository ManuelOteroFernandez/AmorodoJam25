extends Node2D
class_name ZoneManager

@export var zone_size: Vector2 = Vector2(3840.0,2176.0)

var initial_position: Vector2
var trackPlayer: bool = false

func _ready() -> void:
	Global.player_spawn_signal.connect(_on_player_spawn)

func _on_player_spawn():
	Global.player.change_zone_signal.connect(on_player_change_zone)



func on_player_change_zone():
	trackPlayer = true
	$Timer.start()
	
func _process(_delta: float) -> void:
	if trackPlayer:
		var new_index = Global.player.global_position / zone_size
		$CameraTarget.position = initial_position + zone_size * floor(new_index)
	
func _on_timer_timeout() -> void:
	trackPlayer = false
