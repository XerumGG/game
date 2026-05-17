extends Node3D
@onready var hit_rect = $UI/ColorRect
@onready var hp = $UI/HP
@onready var hp_bar = $UI/HP2
@onready var hp_ghost = $UI/HP2_ghost
const ZOMBIE = preload("res://scenes/Zombie.tscn")
const SPAWN_RANGE = 20.0
var target_hp = 30

func _ready() -> void:
	hp.text = "HP: " + str(%Player.health)
	hp_bar.max_value = 30
	hp_bar.value = 30
	hp_ghost.max_value = 30
	hp_ghost.value = 30
	spawn_zombie()

func _process(delta: float) -> void:
	hp_bar.value = lerp(hp_bar.value, float(target_hp), 8.0 * delta)
	if abs(hp_bar.value - float(target_hp)) < 0.5:
		hp_bar.value = target_hp
		hp_ghost.value = target_hp

func spawn_zombie() -> void:
	var markers = $SpawnMarkers.get_children()
	var valid_markers = markers.filter(func(m): 
		return m.global_position.distance_to(%Player.global_position) < SPAWN_RANGE
	)
	
	if valid_markers.size() > 0:
		var random_marker = valid_markers[randi() % valid_markers.size()]
		var zombie = ZOMBIE.instantiate()
		add_child(zombie)
		zombie.global_position = random_marker.global_position
		zombie.player = %Player
	
	var wait_time = randf_range(2.0, 6.0)
	await get_tree().create_timer(wait_time).timeout
	spawn_zombie()

func _on_area_3d_body_entered(body: Node3D) -> void:
	get_tree().reload_current_scene()

func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	target_hp = %Player.health
	hp.text = "HP: " + str(%Player.health)
