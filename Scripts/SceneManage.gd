# Create a new script called SceneManager.gd and add it as an autoload/singleton
extends Node

# Signal that gets emitted when a scene is about to change
signal scene_changing(new_scene_path)

# Add this to your project as an autoload in Project Settings > Autoload
func change_scene(scene_path: String) -> void:
	# Make sure game is unpaused when changing scenes
	get_tree().paused = false
	
	# Reset mouse mode for proper scene transition
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Emit signal for any listeners
	emit_signal("scene_changing", scene_path)
	
	# Change to the new scene
	get_tree().change_scene_to_file(scene_path)

# This function should be called by any scene that needs gameplay mouse behavior
func prepare_gameplay_scene() -> void:
	# Ensure game is unpaused
	get_tree().paused = false
	
	# Set mouse mode for gameplay (captured)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
