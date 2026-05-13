extends Area3D

const SPEED = 5
const RANGE =150

var travelled_dist =0.0

func _physics_process(delta: float) -> void:
	position += transform.basis.x * SPEED*delta
	travelled_dist +=SPEED*delta
	if travelled_dist > RANGE:
		queue_free()



func _on_body_entered(body: Node3D) -> void:
	if body.has_method("hurt"):
		body.hurt()
