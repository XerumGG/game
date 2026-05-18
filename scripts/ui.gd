extends Control
@onready var main = $".."

func _on_restart_pressed() -> void:
	main.state = "play"
	main.get_tree().paused = false
	get_tree().reload_current_scene()
	
