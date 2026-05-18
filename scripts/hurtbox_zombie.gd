extends Area3D

@export var damage = 5.0

signal body_part_hit(dam)

func hit():
	emit_signal("body_part_hit", damage)
