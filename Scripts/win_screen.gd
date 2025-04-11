extends Control

@onready var quit_button = $MainMenu/VBoxContainer/Quit/PlayButtonLink

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass # Replace with function body.

	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_quit_pressed():
	get_tree().quit()
