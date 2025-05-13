class_name Player extends CharacterBody2D
# Define the possible states for the character
enum STATES {
	IDLE,
	RUNNING,
	JUMPING,
	DASHING
}


# Movement variables
@export var speed = 500
@export var jump_force = -1000
@export var gravity = 1800
@export var vertical_velocity = 0
@export var dash_velocity = 100000
@export var dash_distance = 500
@export var dash_time_cooldown = 2


# Current state of the character
var current_state : STATES = STATES.IDLE
var can_double_jump : bool = true
# Input variables
var horizontal_direction = 0

var dash_timer_cooldown : Timer
var dash_start_loc : Vector2
var dash_vector : Vector2

func _ready() -> void:	
	dash_timer_cooldown = $DashTimerCooldown
	dash_timer_cooldown.wait_time = dash_time_cooldown
	dash_timer_cooldown.connect("timeout",Callable(self,"_dashing_ends"))

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
	
	if current_state == STATES.DASHING:
		_state_dashing_phisics_process(delta)
		return
		
	# Apply gravity if not on the floor
	if not is_on_floor():
		vertical_velocity += gravity * delta

	# Calculate the physics movement vector
	velocity = Vector2(horizontal_direction * speed, vertical_velocity)

	move_and_slide() 

	# Transition from JUMPING state when landing
	if is_on_floor() and current_state == STATES.JUMPING and vertical_velocity >= 0:
		if abs(horizontal_direction) > 0.1:
			_change_state(STATES.RUNNING)
		else:
			_change_state(STATES.IDLE)

func _state_idle(_delta):
	# Transition to RUNNING if there's horizontal input
	if abs(horizontal_direction) > 0.1:
		_change_state(STATES.RUNNING)
	# Transition to JUMPING if jump button is pressed and on the floor
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_velocity = jump_force
		_change_state(STATES.JUMPING)

func _state_running(_delta):
	# Transition to IDLE if there's no horizontal input
	if abs(horizontal_direction) < 0.1:
		_change_state(STATES.IDLE)
	# Transition to JUMPING if jump button is pressed and on the floor
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_velocity = jump_force
		_change_state(STATES.JUMPING)

func _state_jumping(_delta):
	# No direct transitions out of JUMPING from input within _process,
	# as landing is handled by _physics_process based on `is_on_floor()`.
	# We allow horizontal movement during jump, which is managed by _physics_process.
	pass
	
func _state_dashing_init():
	_change_state(STATES.DASHING)
	dash_start_loc = global_position
	dash_vector = Vector2(dash_velocity,0)
	if not $AnimatedSprite2D.flip_h:
		dash_vector *= -1 
	
func _state_dashing_phisics_process(delta):
	velocity = dash_vector * delta
	move_and_slide()
	
	if velocity.x == 0 or dash_start_loc.distance_to(global_position) > dash_distance:
		_state_dashing_ends()
	
func _state_dashing_ends():
	_change_state(STATES.IDLE)
	dash_timer_cooldown.start()

func _input(event:InputEvent):
	if event.is_action_pressed("jump"):
		_jump()
	if event.is_action_pressed("dash") and dash_timer_cooldown.is_stopped():
		_state_dashing_init()
	
func _jump():
	if (is_on_floor() and current_state != STATES.JUMPING) or can_double_jump:
		
		if not is_on_floor():
			can_double_jump = false
			
		vertical_velocity = jump_force
		_change_state(STATES.JUMPING)
		
		
func _change_state(new_state:STATES):
	if not can_double_jump and new_state in [STATES.IDLE, STATES.RUNNING]:
		can_double_jump = true
		
	current_state = new_state
