extends Node3D
@export var type = "base"

func _ready() -> void:
	print("heal node: ", $Heal)
	print("base node: ", $Base)
	match type:
		"heal":
			$Heal.visible = true
			$Base.visible = false
		"mag":
			$Heal.visible = false
			$Base.visible = true

func _on_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var main = $".."
		var color_rect = $"../UI/ColorRect"
		match type:
			"heal":
				body.health += 10
				body.health = 30 if body.health > 30 else body.health
				main.target_hp = body.health
				main.update_health()
				color_rect.color = Color(0x75a83a8e)
			"mag":
				body.get_child(1).get_child(0).max_capacity +=10 
				body.get_child(1).get_child(0).capacity = body.get_child(1).get_child(0).max_capacity if body.get_child(1).get_child(0).max_capacity <15 else 15
				color_rect.color = Color(0xc777008e)
		color_rect.visible = true
		await get_tree().create_timer(0.2).timeout
		color_rect.visible = false
		color_rect.color = Color(0xff00008e)
		queue_free()
