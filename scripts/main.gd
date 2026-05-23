extends Node3D
@onready var hit_rect = $UI/ColorRect
@onready var hp = $UI/HP
@onready var hp_bar = $UI/HP2
@onready var hp_ghost = $UI/HP2_ghost
@onready var score_bar = $UI/Score
@onready var restart = $UI/Restart
@onready var bullets = $UI/Bullets
@onready var resume = $UI/Resume

var wait 
var zombie_pos
var dif = 10
var level
var delta_cache = 0.0
var state
var spawning = false
@export var spawn_cap = 10
var spawned = 0

const PICKUP = preload("res://scenes/pickup.tscn")
const ZOMBIE = preload("res://scenes/Zombie.tscn")
const SPAWN_RANGE = 20.0
var target_hp = 30

func _ready() -> void:
	level = 1
	wait = false
	%Player.position = Vector3(2,0,-1)
	state = "start"
	hp.text = "HP: " + str(%Player.health)
	bullets.text = str($Player/Camera3D/Rifle.capacity) +"/"+str($Player/Camera3D/Rifle.max_capacity)+ " BULLETS"
	hp_bar.max_value = 30
	hp_bar.value = 30
	hp_ghost.max_value = 30
	hp_ghost.value = 30
	score_bar.text = "SCORE: " + str(%Player.score)

func _process(delta: float) -> void:
	delta_cache = delta
	match state:
		"start":
			hp_bar.visible = false
			bullets.visible = false
			$UI/CheckBox.visible = true
			hp_ghost.visible = false
			hp.visible = false
			score_bar.visible = false
			restart.visible = false
			resume.visible = false
			$UI/black.visible = true
			$UI/PixilFrame0.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
		"play":
			$UI/CheckBox.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  
			hp_bar.visible = true
			hp_ghost.visible = true
			hp.visible = true
			score_bar.visible = true
			bullets.visible = true
			restart.visible = false
			resume.visible = false
			$UI/black.visible = false
			$UI/Start.visible = false
			$UI/PixilFrame0.visible = true
			if $Player/Camera3D/Rifle.reloading:
				bullets.text = "Reloading...."
			else:
				bullets.text = str($Player/Camera3D/Rifle.capacity) +"/"+str($Player/Camera3D/Rifle.max_capacity)+ " BULLETS"
			score_bar.position = Vector2(0,0)
			update_health()
			
			if level == 1:
				$NavigationRegion3D/Rooms/SpawnMarkers.position = Vector3(0,0,6)
				spawn_cap = 20
				dif = 10
				if %Player.score > 30:
					wait = true
					%Player.health = 30
					%Player.score = 0
					%Player.position = Vector3(2,40,-1)
					level = 2
			elif level == 2:
				$NavigationRegion3D/Rooms/SpawnMarkers.position = Vector3(0,37,6)
				spawn_cap = 35
				dif = 20
				if %Player.score > 50:
					state = "win"
		"dead":
			hp_bar.visible = false
			bullets.visible = false
			hp_ghost.visible = false
			hp.visible = false
			score_bar.position = Vector2(820.0,283.333)
			restart.visible = true
			$UI/black.visible = true
			$UI/PixilFrame0.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
		"win":
			hp_bar.visible = false
			bullets.visible = false
			hp_ghost.visible = false
			hp.visible = false
			$UI/PixilFrame0.visible = false
			score_bar.position = Vector2(820.0,283.333)
			score_bar.text = "YOU WIN"
			restart.visible = true
			$UI/black.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true

func spawn_zombie() -> void:
	if spawning:
		return
	spawning = true
	
	while state == "play":
		while wait:
			await get_tree().process_frame
		
		var markers = $NavigationRegion3D/Rooms/SpawnMarkers.get_children()
		var valid_markers = markers.filter(func(m): 
			return m.global_position.distance_to(%Player.global_position) < SPAWN_RANGE
		)
		
		if valid_markers.size() > 0 and spawned < spawn_cap:
			var random_marker = valid_markers[randi() % valid_markers.size()]
			var zombie = ZOMBIE.instantiate()
			zombie.zombie_dead.connect(reduce)
			zombie.zombie_dead.connect(drop)
			add_child(zombie)
			spawned += 1
			var random_angle = randf() * TAU
			var random_offset = Vector3(cos(random_angle), 0, sin(random_angle)) * randf_range(0.0, 2.5)
			zombie.global_position = random_marker.global_position + random_offset
			zombie.rotation.y = random_angle
			zombie.speed = randf_range(0.1, 0.4) * dif
			zombie.player = %Player
			zombie.health = level * 5 + 10
		
		var wait_time = randf_range(4, 12) / dif
		await get_tree().create_timer(wait_time).timeout
	
	spawning = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	%Player.die()

func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	target_hp = %Player.health
	hp.text = "HP: " + str(%Player.health)

func _on_player_update_score() -> void:
	score_bar.text = "SCORE: " + str(%Player.score)

func _on_player_player_dead() -> void:
	state = "dead"

func reduce(pos):
	%Player.points(2)
	if spawned > 0:
		spawned -= 1

func drop(pos):
	if randi() % 5 == 0:
		var pickup = PICKUP.instantiate()
		pickup.type = "heal" if $Player/Camera3D/Rifle.max_capacity > 20 else "mag"
		add_child(pickup)
		pickup.global_position = pos

func update_health():
	hp.text = "HP: " + str(%Player.health)
	hp_bar.value = lerp(hp_bar.value, float(target_hp), 8.0 * delta_cache)
	if abs(hp_bar.value - float(target_hp)) < 0.5:
		hp_bar.value = target_hp
		hp_ghost.value = target_hp
