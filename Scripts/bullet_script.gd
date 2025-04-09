extends Node3D

const BULLET_SPEED = 10

@onready var mesh = $MeshInstance
@onready var ray = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0,-BULLET_SPEED) * delta
