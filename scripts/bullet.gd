extends Area3D

const SPEED = 205
const RANGE =150

var travelled_dist =0.0

func _physics_process(delta: float) -> void:
	#Moving the bullet 
	position += transform.basis.x * SPEED*delta
	travelled_dist +=SPEED*delta
	#Stops the bullet at Range
	if travelled_dist > RANGE:
		queue_free()



func _on_body_entered(body: Node3D) -> void:
	#Placeholder for hurt mechanic
	if body.has_method("hurt"):
		body.hurt()
