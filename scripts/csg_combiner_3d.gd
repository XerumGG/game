extends CSGCombiner3D

var poss = []
var index = 0

func  _ready() -> void:
	poss = [%f1.position,%f2.position,%f3.position,%f4.position,%f5.position,%f6.position,%f7.position,%f8.position,%f9.position]
	#Gets position of the rooms

#Detects when player enter a room
func _on_hitbox_body_entered(body: Node3D) -> void:
	
	if body == %Player:
		shuffle_fixed(poss,index)

#Function to Shuffle while keeping one value constant
func shuffle_fixed(array:Array, k: int):
	var min_dist = %Player.global_position.distance_to(array[0])
	for i in range(array.size()):
	
			if(%Player.global_position.distance_to(array[i]) < min_dist):
				min_dist=%Player.global_position.distance_to(array[i])
				#Saves the index of the room
				k=i
	
	var fixed_array = array.slice(k,k+1)
	array.remove_at(k)
	array.shuffle()
	array.insert(k,fixed_array[0])
	
	#Shuffles the positons
	for i in range(array.size()):
		get_node("f%d"%(i+1)).position = array[i]
