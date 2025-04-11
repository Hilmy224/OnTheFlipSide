# DeathScreen.gd - Create a new scene for this
extends Control

@onready var retry_button = $VBoxContainer/RetryButton/RetryButton
@onready var color_overlay = $ColorRect
@onready var background_sprite = $AnimatedSprite2D

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button
	retry_button.connect("pressed", Callable(self, "_on_retry_pressed"))

func _on_retry_pressed():
	visible = false
	get_tree().paused = false
	SceneManage.change_scene(get_tree().current_scene.scene_file_path)

func show_death_screen():
	# Show screen and pause game
	visible = true
	get_tree().paused = true
	
	# Explicitly free the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Focus the retry button (helps with keyboard navigation)
	retry_button.grab_focus()
	
	# Create a blood-red fade transition
	var tween = create_tween()
	tween.tween_property(color_overlay, "color", Color(0.8, 0, 0, 0.7), 1.0)
	
