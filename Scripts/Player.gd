extends CharacterBody3D

var speed
const WALK_SPEED = 8.0
const SPRINT_SPEED = 60.0
const DASH_DURATION = 0.2
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.004
const HIT_STAGGER = 8.0

# bob variables
const BOB_FREQ = 0.1 # Added a value since it was 0
const BOB_AMP = 0.08
var t_bob = 0.0

# fov variables
const BASE_FOV = 90.0
const FOV_CHANGE = 1.2

# Player Mode
enum PLAYER_MODE {DEFAULT, STEADY, SWIFT}
var current_mode = PLAYER_MODE.DEFAULT

# STEADY MODE VAR
const STEADY_MAX_STAMINA = 200
var steady_stamina = STEADY_MAX_STAMINA
const STEADY_STAMINA_REGEN = 10  # Per second
const STEADY_DAMAGE_REDUCTION = 0.5  # 50% damage reduction

# SWIFT MODE VAR
const SWIFT_MAX_STAMINA = 150
var swift_stamina = SWIFT_MAX_STAMINA
const SWIFT_STAMINA_REGEN = 15  # Per second
var dash_time_left = 0.0
const DASH_STAMINA_COST = 25

# DEFAULT MODE VAR
const DEFAULT_STAMINA_REGEN = 5  # Per second

# Mode cooldown
const MODE_SWITCH_COOLDOWN = 2.0  # Seconds
var mode_switch_timer = 0.0

# signal
signal player_hit
signal mode_changed(new_mode)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

# Bullets
var bullet = load("res://Scenes/Bullet.tscn")
var instance

@onready var head = $Head
@onready var camera = $Head/Camera3D
#@onready var gun_anim = $Head/Camera3D/Rifle/AnimationPlayer
#@onready var gun_anim2 = $Head/Camera3D/Rifle2/AnimationPlayer
#@onready var gun_barrel = $Head/Camera3D/Rifle/RayCast3D
#@onready var gun_barrel2 = $Head/Camera3D/Rifle2/RayCast3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	# Mode switching
	if mode_switch_timer <= 0:
		if Input.is_action_just_pressed("mode_default"):
			switch_mode(PLAYER_MODE.DEFAULT)
		elif Input.is_action_just_pressed("switch_mode"):
			switch_mode(PLAYER_MODE.STEADY)
		elif Input.is_action_just_pressed("mode_swift"):
			switch_mode(PLAYER_MODE.SWIFT)

func switch_mode(new_mode):
	if current_mode != new_mode:
		current_mode = new_mode
		mode_switch_timer = MODE_SWITCH_COOLDOWN
		emit_signal("mode_changed", current_mode)
		
		# Reset speed when switching modes
		speed = WALK_SPEED
		
		# You could add visual/audio feedback here

func _physics_process(delta):
	# Update mode switch cooldown
	if mode_switch_timer > 0:
		mode_switch_timer -= delta
	
	# Regenerate stamina based on current mode
	if current_mode == PLAYER_MODE.DEFAULT:
		steady_stamina = min(steady_stamina + DEFAULT_STAMINA_REGEN * delta, STEADY_MAX_STAMINA)
		swift_stamina = min(swift_stamina + DEFAULT_STAMINA_REGEN * delta, SWIFT_MAX_STAMINA)
	elif current_mode == PLAYER_MODE.STEADY:
		steady_stamina = min(steady_stamina + STEADY_STAMINA_REGEN * delta, STEADY_MAX_STAMINA)
	elif current_mode == PLAYER_MODE.SWIFT:
		swift_stamina = min(swift_stamina + SWIFT_STAMINA_REGEN * delta, SWIFT_MAX_STAMINA)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Dash - only in SWIFT mode
	if current_mode == PLAYER_MODE.SWIFT:
		if Input.is_action_just_pressed("dash") and swift_stamina >= DASH_STAMINA_COST and dash_time_left <= 0:
			speed = SPRINT_SPEED
			dash_time_left = DASH_DURATION
			swift_stamina -= DASH_STAMINA_COST
		else:
			speed = WALK_SPEED
	else:
		speed = WALK_SPEED
	
	# Update dash timer
	if dash_time_left > 0:
		dash_time_left -= delta
	else:
		dash_time_left = 0
		if speed == SPRINT_SPEED:
			speed = WALK_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 15.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 15.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# Movement and Collision
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func hit(dir):
	var final_hit_stagger = HIT_STAGGER
	
	# Damage reduction in STEADY mode
	if current_mode == PLAYER_MODE.STEADY and steady_stamina > 0:
		final_hit_stagger *= STEADY_DAMAGE_REDUCTION
		steady_stamina = max(0, steady_stamina - 20)  # Cost stamina to reduce damage
	
	emit_signal("player_hit")
	velocity += dir * final_hit_stagger

# You might want to add helper functions to check stamina levels
func get_current_stamina():
	match current_mode:
		PLAYER_MODE.STEADY:
			return steady_stamina
		PLAYER_MODE.SWIFT:
			return swift_stamina
		_:
			return 0.0

func get_max_stamina():
	match current_mode:
		PLAYER_MODE.STEADY:
			return STEADY_MAX_STAMINA
		PLAYER_MODE.SWIFT:
			return SWIFT_MAX_STAMINA
		_:
			return 0.0
