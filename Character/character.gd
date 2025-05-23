class_name Player extends CharacterBody2D
# Define the possible states for the character
enum STATES {
	UNDEFINED,
	IDLE,
	RUNNING,
	JUMPING,
	DASHING,
	CLIMBING,
	FALLING,
	INTERACTING,
	WALL_JUMPING
}

signal change_state_signal
signal change_zone_signal
signal do_action_signal(sender:Player)
signal take_damage_signal


# Movement variables
@export var speed = 50000
@export var jump_force = -1500
@export var gravity = 4200
@export var wall_jum_min_distance = 512
@export var wall_gravity = 800
@export var dash_velocity = 100000
@export var dash_distance = 600
@export var dash_time_cooldown = 2
@export var coyote_distance = 256



# Current state of the character
var current_state : STATES = STATES.IDLE
var _last_state : STATES = STATES.UNDEFINED
var can_double_jump : bool = true

var horizontal_direction = 0
var horizontal_velocity = 0
var vertical_velocity = 0

var dash_timer_cooldown : Timer
var dash_start_loc : Vector2
var dash_vector : Vector2

var can_interact : bool = false

var _coyote_position: Vector2

var _wall_jump_start_pos: Vector2 = Vector2.ZERO 


func _ready() -> void:	
	dash_timer_cooldown = $DashTimerCooldown
	dash_timer_cooldown.wait_time = dash_time_cooldown
	
	
func _process(delta):
	horizontal_direction = Input.get_axis("left", "right")

	# State machine logic
	match current_state:
		STATES.IDLE:
			_state_idle_process(delta)
		STATES.RUNNING:
			_state_running_process(delta)


func _physics_process(delta):
	if current_state in [STATES.UNDEFINED, STATES.INTERACTING]:
		return 
		
	if current_state == STATES.DASHING:
		_state_dashing_phisics_process(delta)
		return
		
	if current_state == STATES.CLIMBING:
		_state_climbing_phisics_process(delta)
		return
		
	if not is_on_floor():
		vertical_velocity += gravity * delta
	
	# Cuando salta de un muro se bloque el movimiento horizontal para que no pueda escalar el muro
	if current_state == STATES.WALL_JUMPING:
		if global_position.distance_to(_wall_jump_start_pos) > wall_jum_min_distance:
			_change_state()
		else:
			velocity = Vector2(horizontal_velocity * delta, vertical_velocity)
	else:
		velocity = Vector2(speed * delta * horizontal_direction, vertical_velocity)

	move_and_slide() 
	
	if is_on_floor() and current_state in [STATES.JUMPING, STATES.FALLING] and vertical_velocity >= 0:
		_change_state()
		return
		
	if is_on_wall_only() and horizontal_direction != 0:
		if not check_floor_distance():
			_change_state(STATES.CLIMBING)
			return
	
	if not is_on_floor() and vertical_velocity >= 0 and current_state != STATES.FALLING:
		_change_state(STATES.FALLING)
		
func check_floor_distance() -> bool:
	var space_state = get_world_2d().get_direct_space_state()
	if not is_instance_valid(space_state):
		return false 

	var ray_origin = global_position

	var ray_end = global_position + Vector2(0, 400)

	var query = PhysicsRayQueryParameters2D.new()
	query.from = ray_origin
	query.to = ray_end
	query.collision_mask = 1
	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	return result and not result.is_empty()

func _state_idle_process(_delta):
	if abs(horizontal_direction) > 0.1:
		_change_state(STATES.RUNNING)

func _state_running_process(_delta):
	if abs(horizontal_direction) < 0.1:
		_change_state(STATES.IDLE)
	

func _state_wall_jump_end():
	_wall_jump_start_pos = Vector2.ZERO
	horizontal_velocity = 0

func _state_dashing_init():
	dash_start_loc = global_position
	dash_vector = Vector2(dash_velocity,0)
	
	if horizontal_direction != 0:
		dash_vector *= horizontal_direction 
	
	
func _state_dashing_phisics_process(delta):
	velocity = dash_vector * delta
	move_and_slide()
	
	var last_col = get_last_slide_collision()
	if (last_col and last_col.get_normal().x) or \
	dash_start_loc.distance_to(global_position) > dash_distance:
		_state_dashing_ends()
	
	
func _state_dashing_ends():
	if current_state == STATES.DASHING:
		_change_state()
		dash_timer_cooldown.start()
	
func _state_climbing_init():
	velocity = Vector2.ZERO
	
func _state_climbing_phisics_process(delta):
	if vertical_velocity < 0:
		vertical_velocity = 0
		
	vertical_velocity = wall_gravity * delta
	velocity = Vector2(horizontal_direction * speed * delta, vertical_velocity)
	move_and_slide()
	
	if not is_on_wall_only():
		_change_state()

func _input(event:InputEvent):
	
	if current_state == STATES.INTERACTING:
		return
	
	if event.is_action_pressed("jump"):
		if current_state == STATES.CLIMBING or _last_state == STATES.CLIMBING:
			if _can_wall_jump():
				_change_state(STATES.WALL_JUMPING)
			else:
				_init_jump_buffer()
				
		else:
			if _can_jump(): 
				_change_state(STATES.JUMPING)
			else:
				_init_jump_buffer()
	
	if event.is_action_pressed("dash") and dash_timer_cooldown.is_stopped() and \
	current_state != STATES.DASHING:
		_change_state(STATES.DASHING)
	
	if can_interact and event.is_action_pressed("interact"):
		_change_state(STATES.INTERACTING)
		do_action_signal.emit(self)
	
func _jump():
	if _can_jump():
		if not is_on_floor() and not _is_in_coyote_time():
			can_double_jump = false
			
		_coyote_position = Vector2.ZERO
		vertical_velocity = jump_force
		
func _can_jump() -> bool:
	return (is_on_floor() and _last_state != STATES.JUMPING) or \
	 can_double_jump or _is_in_coyote_time()
		
func _init_jump_buffer():
	$TimerJumpBuffer.start()
	
func _use_jump_buffer():
	$TimerJumpBuffer.stop()
	_change_state(STATES.JUMPING)
	
func _is_jump_buffer_active() -> bool:
	return not $TimerJumpBuffer.is_stopped()
		
func _is_in_coyote_time() -> bool:
	return abs(global_position.distance_to(_coyote_position)) < coyote_distance
		
func _wall_jump():
	vertical_velocity = jump_force
	horizontal_velocity = speed * get_wall_normal().x
	
	_wall_jump_start_pos = global_position
	
	_coyote_position = Vector2.ZERO
		
func _can_wall_jump() -> bool:
	return current_state == STATES.CLIMBING or \
	(_is_in_coyote_time() and _last_state == STATES.CLIMBING)
		
func _change_state(new_state:STATES = STATES.UNDEFINED):
	if current_state == STATES.WALL_JUMPING and new_state == STATES.WALL_JUMPING:
		return
	
	if new_state == STATES.UNDEFINED:
		if is_on_floor():
			if abs(horizontal_direction) > 0.1:
				new_state = STATES.RUNNING
			else:
				new_state = STATES.IDLE
		elif vertical_velocity < 0:
			new_state = STATES.JUMPING
		else:
			new_state = STATES.FALLING
			
	if current_state in [STATES.RUNNING,STATES.CLIMBING] and new_state == STATES.FALLING:
		_coyote_position = global_position
	
	if current_state == STATES.FALLING and new_state != STATES.JUMPING:
		vertical_velocity = 0
	
	if current_state == STATES.WALL_JUMPING:
		_state_wall_jump_end()
	
	_last_state = current_state
	current_state = new_state
	
	match current_state:
		STATES.JUMPING:
			_jump()
		STATES.CLIMBING:
			_state_climbing_init()
		STATES.DASHING:
			_state_dashing_init()
		STATES.WALL_JUMPING:
			_wall_jump()
			
	if _is_jump_buffer_active() and current_state in [STATES.RUNNING,STATES.IDLE,STATES.CLIMBING]:
		_use_jump_buffer()
		
	if _last_state == STATES.FALLING:
		_coyote_position = Vector2.ZERO
		
	if not can_double_jump and is_on_floor():
		can_double_jump = true
	
	if current_state == STATES.RUNNING:
		$AudioStreamPlayer2D.play()
	else:
		$AudioStreamPlayer2D.stop()
		
	change_state_signal.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	change_zone_signal.emit()
	
func is_on_screen():
	return $VisibleOnScreenNotifier2D.is_on_screen()
	
func end_interaction():
	_change_state()
	
func recieve_damage():
	take_damage_signal.emit()
