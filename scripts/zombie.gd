extends CharacterBody3D

var player = null
var state_machine
var health = 15
var speed = 2
const ATTACK_RANGE = 2.2
signal zombie_dead
@export var player_path : NodePath
@onready var nav_agent = $NavigationAgent3D
@onready var anim = $AnimationTree

func _ready() -> void:
	if player_path:
		player = get_node(player_path)
	state_machine = anim.get("parameters/playback")

func _process(delta: float) -> void:
	if player == null:
		return
	
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			smooth_look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), delta)
		"attack":
			smooth_look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), delta)
	
	anim["parameters/conditions/attack"] = in_range()
	anim["parameters/conditions/run"] = !in_range()
	
	move_and_slide()
	
func smooth_look_at(target: Vector3, delta: float) -> void:
	var direction = (target - global_position)
	if direction.length() < 0.1:
		return
	var target_angle = atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, 5.0 * delta)

func in_range() -> bool:
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func hit_finished():
	if in_range():
		player.hit()


func _on_area_3d_body_part_hit(dam: Variant) -> void:
	health -= dam
	print(health)
	if health <=0:
		emit_signal("zombie_dead")
		player.points(2)
		queue_free()
