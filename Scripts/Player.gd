extends CharacterBody3D

var speed
const WALK_SPEED = 9
const STEADY_SPEED = WALK_SPEED * 0.5
const SPRINT_SPEED = 600.0
const DASH_DURATION = 0.2
const JUMP_VELOCITY = 5
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

# DEFAULT MODE VAR

const DEFAULT_FIRE_RATE = FIRE_RATE * 0.8  # Slightly faster than STEADY but slower than SWIFT

# Player Mode
enum PLAYER_MODE {DEFAULT, STEADY, SWIFT}
var current_mode = PLAYER_MODE.DEFAULT
var switch_mode_change= true

# STEADY MODE VAR
const STEADY_MAX_STAMINA = 200 ## DEFAULT 200
var steady_stamina = STEADY_MAX_STAMINA
const STEADY_STAMINA_REGEN = 10  # Per second
const STEADY_DAMAGE_REDUCTION = 0.7  # 50% damage reduction
const STEADY_BASH_STAMINA_COST = 30
const STEADY_BASH_COOLDOWN = 2.4  # Seconds
var steady_bash_timer = 0.0
const STEADY_BASH_DAMAGE = 1
const STEADY_BASH_RANGE = 2.0
const STEADY_BASH_KNOCKBACK = 10.0

# SWIFT MODE VAR
const SWIFT_MAX_STAMINA = 120 ## DEFAULT 150
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
const SWIFT_FIRE_RATE= FIRE_RATE/3
const RELOAD_TIME = 1.5  # Time to reload
const MAX_AMMO = 6
const DAMAGE = 25
var current_ammo = MAX_AMMO
var fire_timer = 0.0
var reload_timer = 0.0
var is_reloading = false
var random_anim=1

# Health variables
const MAX_HEALTH = 100
var current_health = MAX_HEALTH


# signal
signal player_hit
signal mode_changed(new_mode)
signal weapon_fired
signal weapon_reloaded
signal steady_bash_used


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8



@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var steadyAnimation = $Head/Camera3D/SteadyModeRig/AnimationPlayer
@onready var steadyRig = $Head/Camera3D/SteadyModeRig
@onready var swiftAnimation = $Head/Camera3D/SwiftModeRig/AnimationPlayer
@onready var swiftRig = $Head/Camera3D/SwiftModeRig



#Bullets and Other Offensive
var bullet = load("res://Scenes/bullet_material.tscn")
var bullet_instance
var shot_position
@onready var shoot_direction = $Head/Camera3D/FarAwayObjectToLookAt
@onready var right_gun_barrel = $Head/Camera3D/SteadyRayCast
@onready var left_gun_barrel = $Head/Camera3D/SwifRayCast
@onready var bash_area = $Head/Camera3D/BashArea



#UI ELEMENTS
@onready var ui = $UI
@onready var hp_bar = $UI/StatsBar/MarginContainer/TextureProgressBar
@onready var steady_bar = $UI/StatsBar/HBoxContainer/SteadyBar
@onready var swift_bar = $UI/StatsBar/HBoxContainer/SwiftBar
@onready var ammo_label = $UI/AmmoUI/VBoxContainer/AmmoLabel
@onready var ammo_icon = $UI/AmmoUI/VBoxContainer/AmmoIcon
@onready var mode_animation_player = $UI/StatsBar/HBoxContainer/MarginContainer/PlayerModeIcons
@onready var ui_dialog_box = $UI/Message
@onready var pause_menu = $UI/Panel
@onready var death_screen = $UI/DeathMenu



#Quest Related
var QUEST_KEY=0

func _ready():
	SceneManage.prepare_gameplay_scene()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	 # Initialize UI elements
	steadyAnimation.set_default_blend_time(0.15)
	swiftAnimation.set_default_blend_time(0.15)
	swiftRig.visible=false
	
	update_health_ui()
	update_stamina_ui()
	update_ammo_ui()
	update_mode_icon()

func _unhandled_input(event):
	
	if current_health > 0:
		if event.is_action_pressed("ui_cancel"):
			pause_menu.toggle_visibility()
		
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	# Mode switching
	if mode_switch_timer <= 0:
		if Input.is_action_just_pressed("switch_mode") && switch_mode_change && steady_stamina > 20:
			switch_mode_change = !switch_mode_change
			swiftRig.visible = false
			swiftAnimation.play("Swift_Mode_Stop")
			
			switch_mode(PLAYER_MODE.STEADY)
			steadyRig.visible = true
			steadyAnimation.play("Steady_Mode_Ready")
			
			
		elif Input.is_action_just_pressed("switch_mode") && !switch_mode_change && swift_stamina > 20:
			switch_mode_change = !switch_mode_change
			steadyRig.visible = false
			steadyAnimation.play("Steady_Mode_Stop")
			switch_mode(PLAYER_MODE.SWIFT)
			swiftRig.visible = true
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
		
		# Update ammo when switching modes
		if new_mode == PLAYER_MODE.SWIFT && current_ammo == MAX_AMMO:
			current_ammo = MAX_AMMO * 2
		elif new_mode != PLAYER_MODE.SWIFT && current_ammo > MAX_AMMO:
			current_ammo = MAX_AMMO
			
		update_ammo_ui()
		update_stamina_ui()
		update_mode_icon()
		
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
	Global.debug.add_property("Speed ingame", velocity.length(),6)

	
	
	update_stamina_ui()
	update_mode_icon()
	
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
		# Deplete stamina while in Swift mode (1 point per second)
		swift_stamina = max(0, swift_stamina - 4 * delta)

	# Auto-switch back to DEFAULT mode if out of stamina
	if current_mode == PLAYER_MODE.SWIFT && swift_stamina <= 0:
		switch_mode(PLAYER_MODE.DEFAULT)
		switch_mode_change = true  # Reset switch mode toggle
		swiftRig.visible = false
		steadyRig.visible = true
		steadyAnimation.play("Default_Mode")
		
	if current_mode == PLAYER_MODE.STEADY && steady_stamina <= 0:
		switch_mode(PLAYER_MODE.DEFAULT)
		switch_mode_change = true  # Reset switch mode toggle
		swiftRig.visible = false
		steadyRig.visible = true
		steadyAnimation.play("Default_Mode")

	
	
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
		
	elif current_mode == PLAYER_MODE.STEADY || current_mode == PLAYER_MODE.DEFAULT:
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

# Modify your hit function
func hit(dir,damage_taken):
	take_damage(dir,damage_taken)
	update_health_ui() # Cost stamina to reduce damage
	update_stamina_ui()
	emit_signal("player_hit")
	player_hit_visual_feedback()  # Add visual feedback

# Modify your shoot function
func shoot():
	if fire_timer <= 0 && current_ammo > 0 && !is_reloading && !steadyAnimation.is_playing() && !swiftAnimation.is_playing():
		
		shot_position = shoot_direction.global_transform.origin
		right_gun_barrel.look_at(shot_position,Vector3.UP)
		left_gun_barrel.look_at(shot_position,Vector3.UP)
		bullet_instance =  bullet.instantiate()
		 
		current_ammo -= 1
		
		
		update_ammo_ui()
		weapon_fired_visual_feedback()
		
		# Play the appropriate shoot animation based on current mode
		if current_mode == PLAYER_MODE.DEFAULT:
			fire_timer = DEFAULT_FIRE_RATE
			steadyAnimation.play("Default_Mode_Shoot")
			bullet_instance.position = right_gun_barrel.global_position
			bullet_instance.transform.basis = right_gun_barrel.global_transform.basis
			get_parent().add_child(bullet_instance)
		elif current_mode == PLAYER_MODE.STEADY:
			fire_timer = FIRE_RATE
			steadyAnimation.play("Steady_Mode_Shoot")
			bullet_instance.position = right_gun_barrel.global_position
			bullet_instance.transform.basis = right_gun_barrel.global_transform.basis
			get_parent().add_child(bullet_instance)
		elif current_mode == PLAYER_MODE.SWIFT:
			fire_timer = SWIFT_FIRE_RATE
			if random_anim > 0:
				swiftAnimation.play("Swift_Mode_Shoot_1",-1,2)
				bullet_instance.position = right_gun_barrel.global_position
				bullet_instance.transform.basis = right_gun_barrel.global_transform.basis
				get_parent().add_child(bullet_instance)
				random_anim *= -1
			else:
				swiftAnimation.play("Swift_Mode_Shoot_2",-1,2)
				bullet_instance.position = left_gun_barrel.global_position
				bullet_instance.transform.basis = left_gun_barrel.global_transform.basis
				get_parent().add_child(bullet_instance)
				random_anim *= -1
		
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



# Modify your finish_reload function
func finish_reload():
	if current_mode == PLAYER_MODE.SWIFT:
		current_ammo = MAX_AMMO * 2
	else:
		current_ammo = MAX_AMMO
	
	update_ammo_ui()
	weapon_reloaded_visual_feedback()
	
	is_reloading = false
	emit_signal("weapon_reloaded")

# Modify your steady_bash function
func steady_bash():
	if current_mode == PLAYER_MODE.STEADY && steady_stamina >= STEADY_BASH_STAMINA_COST && steady_bash_timer <= 0:
		steady_stamina -= STEADY_BASH_STAMINA_COST
		steady_bash_timer = STEADY_BASH_COOLDOWN

		
		
		# Play bash animation
		steadyAnimation.play("Steady_Mode_Bash",-1,1.5)
		
		# Process bash area for enemies
		var bash_targets = bash_area.get_overlapping_bodies()
		for target in bash_targets:
			if target.has_method("take_damage") && target.is_in_group("enemy"):
				# Calculate knockback direction
				var player_speed_factor = velocity.length() / WALK_SPEED
				var dynamic_knockback = STEADY_BASH_KNOCKBACK * (1.0 + player_speed_factor)
				var knockback_dir = (target.global_position - global_position).normalized()
				knockback_dir.y = 0  # Add slight upward force
				
				
				var health_restored = 10  # Adjust this value as needed
				heal(health_restored)
				update_health_ui()
				# Apply damage and knockback to enemy
				 
				
				target.take_damage(knockback_dir, STEADY_BASH_DAMAGE, dynamic_knockback)
				
		update_stamina_ui()
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
			
func get_health():
	return current_health

func get_max_health():
	return MAX_HEALTH

func take_damage(dir, amount):
	var final_damage = amount
	var final_hit_stagger = HIT_STAGGER
	
	# Apply damage reduction in STEADY mode
	if current_mode == PLAYER_MODE.STEADY and steady_stamina > 0:
		final_damage *= (1.0 - STEADY_DAMAGE_REDUCTION)
		steady_stamina = max(0, steady_stamina - amount * 0.5)  # Cost stamina to reduce damage
		final_hit_stagger *= STEADY_DAMAGE_REDUCTION
	
	current_health = max(0, current_health - final_damage)
	
	if current_health <= 0:
		# Handle player death
		die()
		
	velocity += dir * final_hit_stagger*2

func heal(amount):
	current_health = min(current_health + amount, MAX_HEALTH)

func die():
	if death_screen:
		# Force mouse to be visible
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		# Set the death screen process mode to ensure it receives input while paused
		death_screen.process_mode = Node.PROCESS_MODE_ALWAYS
		
		# Show death screen
		death_screen.show_death_screen()
	else:
		print("Death screen not found!")

	
func update_health_ui():
	if hp_bar:
		hp_bar.value = current_health
		hp_bar.max_value = MAX_HEALTH

func update_stamina_ui():
	if steady_bar and swift_bar:
		steady_bar.value = steady_stamina
		steady_bar.max_value = STEADY_MAX_STAMINA
		
		swift_bar.value = swift_stamina
		swift_bar.max_value = SWIFT_MAX_STAMINA
		
		# Update visibility based on current mode
		

func update_ammo_ui():
	if ammo_label:
		var effective_max = MAX_AMMO
		if current_mode == PLAYER_MODE.SWIFT:
			effective_max *= 2
		
		ammo_label.text = str(current_ammo) + "/" + str(effective_max)
		
		# Visual feedback for low ammo
		if current_ammo>0:
			if current_ammo <= (effective_max / 4):
				ammo_label.modulate = Color(1, 0.3, 0.3)  # Red when low
			else:
				ammo_label.modulate = Color(1, 1, 1)  # Normal color
			


func update_mode_icon():
	if mode_animation_player:
		# Check if mode switch is on cooldown
		#if mode_switch_timer > 0:
			#mode_animation_player.play("locked_out")
			#return
		#mode_animation_player.play
		# Otherwise show appropriate mode icon
		match current_mode:
			PLAYER_MODE.DEFAULT:
				mode_animation_player.play("default")
			PLAYER_MODE.STEADY:
					mode_animation_player.play("steady_mode")
			PLAYER_MODE.SWIFT:
					mode_animation_player.play("swift_mode")
					
# Add visual feedback for hit
func player_hit_visual_feedback():
	if hp_bar:
		var tween = create_tween()
		tween.tween_property(hp_bar, "modulate", Color(1.5, 0.3, 0.3), 0.1)
		tween.tween_property(hp_bar, "modulate", Color(1, 1, 1), 0.2)

# Add visual feedback for weapon fired
func weapon_fired_visual_feedback():
	if ammo_label:
		var tween = create_tween()
		tween.tween_property(ammo_label, "scale", Vector2(1.2, 1.2), 0.05)
		tween.tween_property(ammo_label, "scale", Vector2(1.0, 1.0), 0.1)

# Add visual feedback for weapon reloaded
func weapon_reloaded_visual_feedback():
	if ammo_label:
		var tween = create_tween()
		tween.tween_property(ammo_label, "modulate", Color(1.2, 1.2, 0.3), 0.1)
		tween.tween_property(ammo_label, "modulate", Color(1, 1, 1), 0.2)
		
func add_key(amount):
	QUEST_KEY+=amount
	print(QUEST_KEY)
	
func activate_ui_dialogbox(message):
	if ui_dialog_box != null:
		ui_dialog_box.display_message(message)
	else:
		print("Dialog box not found!")
