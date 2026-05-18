extends Node3D
@onready var hit_rect = $UI/ColorRect
@onready var hp = $UI/HP
@onready var hp_bar = $UI/HP2
@onready var hp_ghost = $UI/HP2_ghost
@onready var score_bar = $UI/Score
@onready var restart = $UI/Restart
@onready var bullets = $UI/Bullets

var state
@export var spawn_cap =10
var spawned = 0

const ZOMBIE = preload("res://scenes/Zombie.tscn")
const SPAWN_RANGE = 20.0
var target_hp = 30

func _ready() -> void:
	state = "play"
	hp.text = "HP: " + str(%Player.health)
	bullets.text = str($Player/Camera3D/Rifle.capacity) +"/"+str($Player/Camera3D/Rifle.max_capacity)+ " BULLETS"
	hp_bar.max_value = 30
	hp_bar.value = 30
	hp_ghost.max_value = 30
	hp_ghost.value = 30
	score_bar.text = "SCORE: " + str(%Player.score)
	spawn_zombie()

func _process(delta: float) -> void:
	
	match state:
		"play":
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  
			hp_bar.visible = true
			hp_ghost.visible= true
			hp.visible = true
			bullets.visible = true
			restart.visible = false
			bullets.text = str($Player/Camera3D/Rifle.capacity) +"/"+str($Player/Camera3D/Rifle.max_capacity)+ " BULLETS"
			score_bar.position = Vector2(0,0)
			hp_bar.value = lerp(hp_bar.value, float(target_hp), 8.0 * delta)
			if abs(hp_bar.value - float(target_hp)) < 0.5:
				hp_bar.value = target_hp
				hp_ghost.value = target_hp
		"dead":
			hp_bar.visible = false
			bullets.visible = false
			hp_ghost.visible= false
			hp.visible = false
			score_bar.position = Vector2(495,170)
			restart.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
			
func spawn_zombie() -> void:
	var markers = $SpawnMarkers.get_children()
	var valid_markers = markers.filter(func(m): 
		return m.global_position.distance_to(%Player.global_position) < SPAWN_RANGE
	)
	
	if valid_markers.size() > 0 and spawned<spawn_cap:
		var random_marker = valid_markers[randi() % valid_markers.size()]
		var zombie = ZOMBIE.instantiate()
		zombie.zombie_dead.connect(reduce)
		add_child(zombie)
		spawned+=1
		var random_angle = randf() * TAU
		var random_offset = Vector3(cos(random_angle), 0, sin(random_angle)) * randf_range(0.0, 2.5)
		zombie.global_position = random_marker.global_position + random_offset
		zombie.speed = randf_range(2,5)
		zombie.player = %Player
	
	var wait_time = randf_range(0.5,2)
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


func _on_player_update_score() -> void:
	score_bar.text = "SCORE: "+str(%Player.score)

func _on_player_player_dead() -> void:
	state = "dead"

func reduce():
	if spawned>0:
		spawned -=1
