extends CSGCombiner3D
var poss = []
func  _ready() -> void:
	poss = [%f1.position,%f2.position,%f3.position,%f4.position]

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_menu"):
		poss.shuffle()
		print(poss)
		%f1.position=poss[0]
		%f2.position=poss[1]
		%f3.position=poss[2]
		%f4.position=poss[3]
