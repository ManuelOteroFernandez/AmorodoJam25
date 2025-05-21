extends Node2D
class_name ZoneManager

@export var margin_y: float = 256
@export var zone_size: Vector2 = Vector2(3840.0,2048.0)
@export var camera_zoom: float = 0.3

var initial_position: Vector2
var trackPlayer: bool = false

var _zone_size_margin

func _ready() -> void:
	Global.player_spawn_signal.connect(_on_player_spawn)
	$CameraTarget/Camera2D.zoom = Vector2(camera_zoom,camera_zoom)
	
	_zone_size_margin = zone_size - Vector2(0,margin_y)

func _on_player_spawn():
	Global.player.change_zone_signal.connect(on_player_change_zone)
	on_player_change_zone()


func on_player_change_zone():
	if trackPlayer:
		return
		
	trackPlayer = true
	$Timer.start()
	_track_player()
	
func _track_player():
	var new_index = Global.player.global_position / _zone_size_margin
	$CameraTarget.position = initial_position + _zone_size_margin * floor(new_index)
	
	
func _on_timer_timeout() -> void:
	trackPlayer = false
	if not Global.player.is_on_screen():
		_track_player()
