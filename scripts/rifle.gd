extends Node3D

@export var max_capacity = 35
var reload = 15
var capacity = reload
var reloading :bool

func _on_player_shot() -> void:
	capacity -=1 if capacity else capacity

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reload") and !reloading and $"../..".weapon =="gun" and max_capacity:
		reloading = true
		$AnimationPlayer.play("reload")
		await get_tree().create_timer(1.5).timeout
		reload = 15 -capacity
		if capacity+max_capacity < 15:
			capacity +=max_capacity
		else:
			capacity = 15
		max_capacity -= reload
		max_capacity = 0 if max_capacity <0 else max_capacity
		reloading = false
