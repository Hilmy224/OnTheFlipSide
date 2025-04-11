extends Node3D
@onready var gate = $StoppingPlane/StaticBody3D
@onready var gateVisual = $Gate
@export var player_path: NodePath
var player
var gate_opened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	if player == null:
		push_error("Player node not found. Check player_path.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not gate_opened and player != null:
		if player.QUEST_KEY >= 3:
			open_gate()

func open_gate():
	gate_opened = true
	
	# Disable the collision by disabling the CollisionShape3D
	var collision_shape = gate.get_node("CollisionShape3D")
	if collision_shape:
		collision_shape.disabled = true
	
	# Alternative: disable the entire StaticBody3D
	#gate.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Hide the gate visual
	gateVisual.visible = false
	
	# Show dialog that a door has opened
	if player.has_method("activate_ui_dialogbox"):
		player.activate_ui_dialogbox("A door has opened somewhere...")
