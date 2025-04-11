extends Node3D

# Define the two chest modes
enum ChestMode {KEY, MASK}
@export var mode: ChestMode = ChestMode.KEY  # Default to key mode
@export var player_path: NodePath  # Path to player for passing to SpawnEnemy
@export var enemy_scene: PackedScene  # Enemy scene to spawn
@export var number_to_spawn = 6

# References to child nodes
@onready var trigger_area = $TriggerAreaEvent
@onready var spawn_area = $TriggerAreaEvent/SpawnArea
@onready var key_mesh = $TriggerAreaEvent/Key
@onready var mask_mesh = $TriggerAreaEvent/Mask
@onready var trigger_spawn = $TriggerAreaEvent/CollisionShape3D


# Player stats variable
var player_keys = 0
var Oneshot = true

func _ready():
	# Connect to the area entered signal from TriggerArea
	if trigger_area.has_node("CollisionShape3D"):
		trigger_area.connect("body_entered", _on_trigger_area_body_entered)
	
	# Set up the initial appearance based on mode
	update_visual_state()

func update_visual_state():
	# Show correct mesh based on mode
	if mode == ChestMode.KEY:
		if key_mesh:
			key_mesh.visible = true
		if mask_mesh:
			mask_mesh.visible = false
	else:  # MASK mode
		if key_mesh:
			key_mesh.visible = false
		if mask_mesh:
			mask_mesh.visible = true

func _on_trigger_area_body_entered(body):
	# Check if the body is the player
	if Oneshot:
		if body.is_in_group("player"):
			process_chest_interaction(body)
			Oneshot=false

func process_chest_interaction(player):
	if mode == ChestMode.KEY:
		# Spawn enemies
		spawn_enemies()
		
		# Add key to player inventory
		player_keys += 1
		
		
			
		if key_mesh:
			key_mesh.visible = false
			
		# Update player's key count
		if player.has_method("add_key"):
			player.add_key(1)
		else:
			print("Player obtained a key! Total keys: " + str(player_keys))
		
	else:  # MASK mode
		# Go directly to win screen
		if mask_mesh:
			mask_mesh.visible = false
		go_to_win_screen()
	
	# Hide the chest interact after interaction
	#trigger_spawn.disabled=true

func spawn_enemies():
	# Get player for navigation target
	var player = get_node_or_null(player_path)
	if player == null:
		push_warning("Player node not found at path: " + str(player_path))
	
	if enemy_scene == null:
		push_error("No enemy scene assigned to chest!")
		return
		

	
	for i in range(number_to_spawn):
		var enemy = enemy_scene.instantiate()
		enemy.player_path=player_path
		get_parent().add_child(enemy)
		
		## Set up references if the enemy has these nodes
		#if enemy.has_node("NavigationAgent3D"):
			#var nav_agent = enemy.get_node("NavigationAgent3D")
			## If player is valid, set target
			#if player != null:
				#nav_agent.target_position = player.global_position
		#
		## Handle animation tree if exists
		#if enemy.has_node("AnimationTree"):
			#var anim_tree = enemy.get_node("AnimationTree")
			#anim_tree.active = true
			#
		## Set position using spawn area
		enemy.global_position = get_random_spawn_position()

func get_random_spawn_position() -> Vector3:
	var shape = spawn_area.get_node("CollisionShape3D").shape
	var extents = shape.extents
	var origin = spawn_area.global_transform.origin
	var random_x = randf_range(-extents.x, extents.x)
	var random_z = randf_range(-extents.z, extents.z)
	return Vector3(origin.x + random_x, origin.y, origin.z + random_z)

func go_to_win_screen():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")
