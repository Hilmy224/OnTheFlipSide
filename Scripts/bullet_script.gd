extends Node3D

const BULLET_SPEED = 120

@onready var mesh = $MeshInstance
@onready var ray = $RayCast3D
@onready var blood_Particle = $blood

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0,0,-BULLET_SPEED) * delta
	if ray.is_colliding():
		mesh.visible=false
		ray.enabled= false
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().hit()
			blood_Particle.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout():
	queue_free()
