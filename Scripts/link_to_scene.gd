extends LinkButton

@export_file("*.tscn") var scene_to_load: String

func _ready():
	self.pressed.connect(_on_pressed)

func _on_pressed():
	if scene_to_load != "":
		SceneManage.change_scene(scene_to_load)
	else:
		push_warning("No scene assigned to 'scene_to_load'")
