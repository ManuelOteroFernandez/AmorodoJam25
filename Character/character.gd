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
}

signal change_state_signal
signal change_zone_signal
signal do_action_signal(sender:Player)
signal take_damage_signal


# Movement variables
@export var speed = 50000
@export var jump_force = -1000
@export var gravity = 1800
@export var wall_gravity = 800
@export var dash_velocity = 100000
@export var dash_distance = 500
@export var dash_time_cooldown = 2


# Current state of the character
var current_state : STATES = STATES.IDLE
var can_double_jump : bool = true

var horizontal_direction = 0
var horizontal_velocity = 0
var vertical_velocity = 0

var dash_timer : Timer
var dash_timer_cooldown : Timer
var dash_start_loc : Vector2
var dash_vector : Vector2

var block_input
var can_interact : bool = false

func _ready() -> void:	
	dash_timer_cooldown = $DashTimerCooldown
	dash_timer_cooldown.wait_time = dash_time_cooldown
	
	dash_timer = $DashTimer
	dash_timer.timeout.connect(_state_dashing_ends)

func _process(delta):
	horizontal_direction = Input.get_axis("left", "right")

	# State machine logic
	match current_state:
		STATES.IDLE:
			_state_idle(delta)
		STATES.RUNNING:
			_state_running(delta)
		STATES.JUMPING:
			_state_jumping(delta)	


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
	
	# Cuando salta de un muro se bloque el input para que no pueda escalar el muro
	block_input = abs(horizontal_velocity) > 0.1 and current_state == STATES.JUMPING
	if block_input :
		velocity = Vector2(horizontal_velocity * delta, vertical_velocity)
	else:
		velocity = Vector2(speed * delta * horizontal_direction, vertical_velocity)

	move_and_slide() 
	# Transition from JUMPING state when landing
	if is_on_floor() and current_state in [STATES.JUMPING, STATES.FALLING] and vertical_velocity >= 0:
		_change_state()
		return
		
	if is_on_wall_only() and horizontal_direction != 0:
		if not check_floor_distance():
			_state_climbing_init()
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

func _state_idle(_delta):
	if abs(horizontal_direction) > 0.1:
		_change_state(STATES.RUNNING)

func _state_running(_delta):
	if abs(horizontal_direction) < 0.1:
		_change_state(STATES.IDLE)
	

func _state_jumping(_delta):
	# No direct transitions out of JUMPING from input within _process,
	# as landing is handled by _physics_process based on `is_on_floor()`.
	# We allow horizontal movement during jump, which is managed by _physics_process.
	pass
	
func _state_dashing_init():
	_change_state(STATES.DASHING)
	dash_start_loc = global_position
	dash_vector = Vector2(dash_velocity,0)
	if $AnimatedSprite2D.flip_h:
		dash_vector *= -1 
	
	dash_timer.start()
	
func _state_dashing_phisics_process(delta):
	velocity = dash_vector * delta
	move_and_slide()
	
	if velocity.x == 0 or dash_start_loc.distance_to(global_position) > dash_distance:
		_state_dashing_ends()
	
	
func _state_dashing_ends():
	if current_state == STATES.DASHING:
		_change_state()
		dash_timer_cooldown.start()
	
func _state_climbing_init():
	_change_state(STATES.CLIMBING)
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
	if block_input: return
	
	if event.is_action_pressed("jump"):
		if current_state == STATES.CLIMBING:
			_wall_jump()
		else:
			_jump()
			
	if event.is_action_pressed("dash") and dash_timer_cooldown.is_stopped():
		_state_dashing_init()
		
	if can_interact and event.is_action_pressed("interact"):
		_change_state(STATES.INTERACTING)
		do_action_signal.emit(self)
	
func _jump():
	if (is_on_floor() and current_state != STATES.JUMPING) or can_double_jump:
		
		if not is_on_floor():
			can_double_jump = false
			
		vertical_velocity = jump_force
		_change_state(STATES.JUMPING)
		
func _wall_jump():	
	if current_state == STATES.CLIMBING:
		_change_state(STATES.JUMPING)
		vertical_velocity = jump_force
		horizontal_velocity = speed * get_wall_normal().x 
		#print("velocidad inicial=> {0}".format([horizontal_velocity]))
		
func _change_state(new_state:STATES = STATES.UNDEFINED):
	if current_state == STATES.INTERACTING:
		block_input = false
	if new_state == STATES.INTERACTING:
		block_input = true
		
	if current_state == STATES.FALLING and new_state != STATES.JUMPING:
		vertical_velocity = 0
	
	if current_state == STATES.JUMPING and horizontal_velocity != 0:
		horizontal_velocity = 0	
		
	if new_state != STATES.UNDEFINED:
		current_state = new_state
	elif is_on_floor():
		if abs(horizontal_direction) > 0.1:
			current_state = STATES.RUNNING
		else:
			current_state = STATES.IDLE
	elif vertical_velocity < 0:
		current_state = STATES.JUMPING
	else:
		current_state = STATES.FALLING
		
	if not can_double_jump and current_state in [STATES.IDLE, STATES.RUNNING]:
		can_double_jump = true
	
	change_state_signal.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	change_zone_signal.emit()
	
func end_interaction():
	_change_state()
	
func recieve_damage():
	take_damage_signal.emit()
