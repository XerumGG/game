extends Node3D

@export var max_capacity = 35
var capacity = max_capacity
var reloading :bool

func _on_player_shot() -> void:
	capacity -=1 if capacity else capacity

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reload") and !reloading:
		reloading = true
		$AnimationPlayer.play("reload")
		await get_tree().create_timer(1.5).timeout
		capacity = max_capacity
		reloading = false
