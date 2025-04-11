extends Panel
# Create a new script called DialogBox.gd


@onready var label = $Label
@onready var timer = $Timer

func _ready():
	# Hide dialog box by default
	visible = false
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func display_message(message):
	label.text = message
	visible = true
	timer.start(3.0)  # Show message for 3 seconds

func _on_timer_timeout():
	visible = false
