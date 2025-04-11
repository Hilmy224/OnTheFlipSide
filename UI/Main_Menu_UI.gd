# MainMenu.gd - Attach to your MainMenu node
extends Control


@onready var quit_button = $MainMenu/VBoxContainer/Quit/PlayButtonLink

# Background animation references
@onready var color_overlay = $ColorRect

func _ready():
	# Set up button connections

	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_quit_pressed():
	get_tree().quit()
