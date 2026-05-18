extends Node3D

@export var max_capacity = 35
var capacity = max_capacity

func _on_player_shot() -> void:
	capacity -=1 if capacity else capacity
	print(capacity)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reload"):
		capacity = max_capacity
