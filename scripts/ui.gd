extends Control
@onready var main = $".."
var counting_down = false

func _ready() -> void:
	$CheckBox.button_pressed = true
	%Player.bob_enabled = $CheckBox.button_pressed

func  _process(delta: float) -> void:
	if main.wait and !counting_down:
		counting_down = true
		main.wait = false
		countdown()
		
	if Input.is_action_just_pressed("esc"):
		if main.state == "play":
			main.state = "paused" 
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
			$Score.position = Vector2(820.0,283.333)
			$Restart.visible = true
			$Resume.visible = true
			$black.visible = true
			$HP.visible = false
			$HP2.visible = false
			$Bullets.visible = false
			$HP2_ghost.visible = false
			$PixilFrame0.visible = false
			$CheckBox.visible = true
		elif main.state == "paused":
			get_tree().paused = false
			main.state = "play"
			main.spawn_zombie()

func _on_restart_pressed() -> void:
	main.state = "start"
	main.get_tree().paused = false
	get_tree().reload_current_scene()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	main.state = "play"

func countdown() -> void:
	$Label.visible = true
	for i in range(3, 0, -1):
		$Label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	$Label.text = "WAVE 2!"
	await get_tree().create_timer(1.0).timeout
	$Label.visible = false
	counting_down = false


func _on_start_pressed() -> void:
	main.state = "play"
	main.get_tree().paused = false
	main.spawn_zombie()


func _on_check_box_toggled(toggled_on: bool) -> void:
	print("toggled: ", toggled_on)
	print("player: ",%Player)
	%Player.bob_enabled = toggled_on
	print(%Player.bob_enabled)
