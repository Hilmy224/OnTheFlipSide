extends CharacterBody3D

var speed
const WALK_SPEED = 9.0
const STEADY_SPEED = WALK_SPEED * 0.5
const SPRINT_SPEED = 600.0
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
const FOV_CHANGE = 1.4
var current_fov_change = FOV_CHANGE

# Player Mode
enum PLAYER_MODE {DEFAULT, STEADY, SWIFT}
var current_mode = PLAYER_MODE.STEADY
var switch_mode_change= true

# STEADY MODE VAR
const STEADY_MAX_STAMINA = 100000 ## DEFAULT 200
var steady_stamina = STEADY_MAX_STAMINA
const STEADY_STAMINA_REGEN = 10  # Per second
const STEADY_DAMAGE_REDUCTION = 0.5  # 50% damage reduction
const STEADY_BASH_STAMINA_COST = 30
const STEADY_BASH_COOLDOWN = 1.0  # Seconds
var steady_bash_timer = 0.0
const STEADY_BASH_DAMAGE = 50
const STEADY_BASH_RANGE = 2.0
const STEADY_BASH_KNOCKBACK = 15.0

# SWIFT MODE VAR
const SWIFT_MAX_STAMINA = 100000 ## DEFAULT 150
var swift_stamina = SWIFT_MAX_STAMINA
const SWIFT_STAMINA_REGEN = 15  # Per second
var dash_time_left = 0.0
const DASH_STAMINA_COST = 25

# DEFAULT MODE VAR
const DEFAULT_STAMINA_REGEN = 10  # Per second

# Mode cooldown
const MODE_SWITCH_COOLDOWN = 1.6  # Seconds
var mode_switch_timer = 0.0

# Weapon variables
const FIRE_RATE = 0.25  # Time between shots
const RELOAD_TIME = 1.5  # Time to reload
const MAX_AMMO = 30
const DAMAGE = 25
var current_ammo = MAX_AMMO
var fire_timer = 0.0
var reload_timer = 0.0
var is_reloading = false
var random_anim=1

# signal
signal player_hit
signal mode_changed(new_mode)
signal weapon_fired
signal weapon_reloaded
signal steady_bash_used

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

# Bullets
var bullet = load("res://Scenes/Bullet.tscn")
var instance

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var steadyAnimation = $Head/Camera3D/SteadyModeRig/AnimationPlayer
@onready var swiftAnimation = $Head/Camera3D/SwiftModeRig/AnimationPlayer
#@onready var steady_gun_anim = $Head/Camera3D/SteadyModeRig/Rifle/AnimationPlayer
#@onready var swift_gun_anim = $Head/Camera3D/SwiftModeRig/Rifle/AnimationPlayer
#@onready var steady_gun_barrel = $Head/Camera3D/SteadyModeRig/Rifle/RayCast3D
#@onready var swift_gun_barrel = $Head/Camera3D/SwiftModeRig/Rifle/RayCast3D
#@onready var bash_raycast = $Head/BashRaycast

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	# Mode switching
	if mode_switch_timer <= 0:
		if Input.is_action_just_pressed("switch_mode") && switch_mode_change && steady_stamina > 20:
			switch_mode_change = !switch_mode_change
			swiftAnimation.play("Swift_Mode_Stop")
			switch_mode(PLAYER_MODE.STEADY)
			steadyAnimation.play("Steady_Mode_Ready")
			
		elif Input.is_action_just_pressed("switch_mode") && !switch_mode_change && swift_stamina > 20:
			switch_mode_change = !switch_mode_change
			steadyAnimation.play("Steady_Mode_Stop")
			switch_mode(PLAYER_MODE.SWIFT)
			swiftAnimation.play("Swift_Mode_Ready")
	
	# Shooting
	if Input.is_action_just_pressed("shoot") && current_ammo > 0 && !is_reloading && fire_timer <= 0:
		shoot()
	
	# Reloading
	if Input.is_action_just_pressed("reload") && !is_reloading && current_ammo < MAX_AMMO:
		start_reload()
	
	# Steady Bash - Only in STEADY mode
	if current_mode == PLAYER_MODE.STEADY && Input.is_action_just_pressed("bash") && steady_stamina >= STEADY_BASH_STAMINA_COST && steady_bash_timer <= 0:
		steady_bash()

func switch_mode(new_mode):
	if current_mode != new_mode:
		current_mode = new_mode
		mode_switch_timer = MODE_SWITCH_COOLDOWN
		emit_signal("mode_changed", current_mode)
		
		# Reset speed when switching modes
		if new_mode == PLAYER_MODE.STEADY:
			speed = STEADY_SPEED
		else:
			speed = WALK_SPEED
		
		# Interrupt reloading if switching modes
		if is_reloading:
			is_reloading = false
			reload_timer = 0.0

func _physics_process(delta):
	#Logs
	Global.debug.add_property("Mode", current_mode,1)
	Global.debug.add_property("Speed",speed,2)
	Global.debug.add_property("Steady_Stamina",steady_stamina,3)
	Global.debug.add_property("Swift_Stamina",swift_stamina,4)
	Global.debug.add_property("Ammo", str(current_ammo) + "/" + str(MAX_AMMO), 5)
	
	# Update timers
	if mode_switch_timer > 0:
		mode_switch_timer -= delta
	
	if fire_timer > 0:
		fire_timer -= delta
	
	if reload_timer > 0:
		reload_timer -= delta
		if reload_timer <= 0 && is_reloading:
			finish_reload()
	
	if steady_bash_timer > 0:
		steady_bash_timer -= delta
	
	# Regenerate stamina based on current mode
	if current_mode == PLAYER_MODE.DEFAULT:
		steady_stamina = min(steady_stamina + DEFAULT_STAMINA_REGEN * delta, STEADY_MAX_STAMINA)
		swift_stamina = min(swift_stamina + DEFAULT_STAMINA_REGEN * delta, SWIFT_MAX_STAMINA)
	elif current_mode == PLAYER_MODE.STEADY:
		swift_stamina = min(swift_stamina + SWIFT_STAMINA_REGEN * delta, SWIFT_MAX_STAMINA)
	elif current_mode == PLAYER_MODE.SWIFT:
		steady_stamina = min(steady_stamina + STEADY_STAMINA_REGEN * delta, STEADY_MAX_STAMINA)
	
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
	
	if current_mode == PLAYER_MODE.SWIFT and dash_time_left < 0:
		speed = WALK_SPEED
		current_fov_change = FOV_CHANGE
		
	elif current_mode == PLAYER_MODE.STEADY:
		speed = STEADY_SPEED
		current_fov_change = 1.2
	
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
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED)
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
		steady_stamina = max(0, steady_stamina - 10)  # Cost stamina to reduce damage
	
	emit_signal("player_hit")
	velocity += dir * final_hit_stagger

# Weapon functionality
func shoot():
	if fire_timer <= 0 && current_ammo > 0 && !is_reloading:
		current_ammo -= 1
		fire_timer = FIRE_RATE
		
		
		# Play the appropriate shoot animation based on current mode
		if current_mode == PLAYER_MODE.STEADY:
			steadyAnimation.play("Steady_Mode_Shoot")
			
			## Use steady mode raycast/bullet logic
			#if steady_gun_barrel.is_colliding():
				#var target = steady_gun_barrel.get_collider()
				#if target.has_method("take_damage"):
					#target.take_damage(DAMAGE)
			#else:
				## Create a bullet instance for steady mode
				#instance = bullet.instantiate()
				#instance.global_transform = steady_gun_barrel.global_transform
				#get_tree().get_root().add_child(instance)
		
		elif current_mode == PLAYER_MODE.SWIFT:
			if random_anim>0:
				swiftAnimation.play("Swift_Mode_Shoot_1")
				random_anim*=-1
			else:
				swiftAnimation.play("Swift_Mode_Shoot_2")
				random_anim*=-1
			
			## Use swift mode raycast/bullet logic
			#if swift_gun_barrel.is_colliding():
				#var target = swift_gun_barrel.get_collider()
				#if target.has_method("take_damage"):
					#target.take_damage(DAMAGE)
			#else:
				## Create a bullet instance for swift mode
				#instance = bullet.instantiate()
				#instance.global_transform = swift_gun_barrel.global_transform
				#get_tree().get_root().add_child(instance)
		
		emit_signal("weapon_fired")
		
		# Auto reload if out of ammo
		if current_ammo <= 0:
			start_reload()

func start_reload():
	if !is_reloading && current_ammo < MAX_AMMO:
		is_reloading = true
		reload_timer = RELOAD_TIME
		
		# Play the appropriate reload animation based on current mode
		if current_mode == PLAYER_MODE.STEADY:
			steadyAnimation.play("Steady_Mode_Reload")
		elif current_mode == PLAYER_MODE.SWIFT:
			swiftAnimation.play("Swift_Mode_Reload")

func finish_reload():
	current_ammo = MAX_AMMO
	is_reloading = false
	emit_signal("weapon_reloaded")

func steady_bash():
	if current_mode == PLAYER_MODE.STEADY && steady_stamina >= STEADY_BASH_STAMINA_COST && steady_bash_timer <= 0:
		steady_stamina -= STEADY_BASH_STAMINA_COST
		steady_bash_timer = STEADY_BASH_COOLDOWN
		
		# Play bash animation
		steadyAnimation.play("Steady_Mode_Bash")
		
		## Check for enemies in bash range
		#bash_raycast.force_raycast_update()
		#if bash_raycast.is_colliding():
			#var target = bash_raycast.get_collider()
			#if target.has_method("take_damage"):
				#var dir = (target.global_transform.origin - global_transform.origin).normalized()
				#target.take_damage(STEADY_BASH_DAMAGE)
				#
				## Apply knockback
				#if target is RigidBody3D:
					#target.apply_central_impulse(dir * STEADY_BASH_KNOCKBACK)
				#elif target.has_method("apply_knockback"):
					#target.apply_knockback(dir * STEADY_BASH_KNOCKBACK)
		
		emit_signal("steady_bash_used")

# Helper functions to check stamina levels
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
