extends CharacterBody3D
var player = null
var state_machine
const SPEED = 4.5
const ATTACK_RANGE = 2.0
const ATTACK_DAMAGE = 40.0
var HEALTH = 4
@export var player_path : NodePath
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var collision_shape_3d = $CollisionShape3D

# Add knockback variables
var knockback_velocity = Vector3.ZERO
var knockback_recovery = 5.0  # How quickly the knockback effect fades

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Don't reset velocity completely at the start of each frame
	# Instead, handle knockback recovery
	knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_recovery * delta)
	
	var movement_velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"shade_walk":
			# Navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			movement_velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			
			# Only rotate if not being knocked back significantly
			if knockback_velocity.length() < SPEED * 0.5:
				rotation.y = lerp_angle(rotation.y, atan2(-movement_velocity.x, -movement_velocity.z), delta * 10.0)
		"shade_attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Combine movement with knockback
	velocity = movement_velocity + knockback_velocity
	
	## Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir, ATTACK_DAMAGE)

# Get Shot
func _on_area_3d_body_part_hit(dam):
	take_damage(0, dam)
		
func take_damage(dir, damage_amount, knockback_force = 0):
	HEALTH -= damage_amount
	
	# Apply knockback to the knockback_velocity instead
	if knockback_force > 0:
		knockback_velocity = dir * knockback_force * 2
	
	if HEALTH <= 0:
		collision_shape_3d.disabled = true
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()
