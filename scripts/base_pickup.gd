extends Area3D
@onready var main = $".."
signal update_health

@export var type : String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if can_pickup(body):
		on_pickup(body)

# override these in child scripts
func can_pickup(body: Node3D) -> bool:
	return body.is_in_group("player")

func on_pickup(body: Node3D) -> void:
	match type:
		"heal":
			if %Player.health < 30:
				%Player.health +=10
				if %Player.health > 30:
					%Player.health = 30
				main.update_health()
		"":
			pass
	queue_free()
