
	
# PauseMenu.gd
extends Control

@onready var retry_button = $PauseMenu/VBoxContainer/Retry/PlayButtonLink
@onready var main_menu_button = $PauseMenu/VBoxContainer/Main_Menu/PlayButtonLink

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if not retry_button.is_connected("pressed", on_retry_pressed):
		retry_button.connect("pressed", on_retry_pressed)

func on_retry_pressed():
	toggle_visibility()  # Hide menu first
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	toggle_visibility()  # Hide menu first
	get_tree().change_scene_to_file("res://Scenes/main_menu_ui.tscn")

func toggle_visibility():
	visible = !visible
	get_tree().paused = visible
	
	# Handle mouse cursor visibility and mode
	if visible:
		# Show cursor when paused
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		# Capture cursor when unpaused (returning to game)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
