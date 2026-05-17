extends CharacterBody3D

var player = null
var state_machine
const SPEED = 2
const ATTACK_RANGE = 2.2
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
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	anim["parameters/conditions/attack"] = in_range()
	anim["parameters/conditions/run"] = !in_range()
	
	move_and_slide()

func in_range() -> bool:
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func hit_finished():
	if in_range():
		player.hit()
