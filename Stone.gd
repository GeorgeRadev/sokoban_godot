extends KinematicBody

func _ready():
	pass # Replace with function body.

var moving:bool = false
var to_delta:float = -1

var start_x:float = 0.0
var start_z:float = 0.0
var end_x:float = 0.0
var end_z:float = 0.0


func _physics_process(delta):
	if to_delta > 0: # expiration time
		transform.origin = Vector3(end_x + (to_delta)*(start_x - end_x), 0, end_z + (to_delta)*(start_z - end_z))
		
		to_delta -= delta
		if to_delta < 0:
			print("moving done")
			moving = false
			to_delta = -1
			transform.origin = Vector3(end_x, 0, end_z)
			parent.stone_moved()
			

func push_stone(from_position: Vector3):
	if moving  or to_delta > 0: return
	moving = true
	var current_x = transform.origin.x
	var current_z = transform.origin.z
	var from_x = from_position.x
	var from_z = from_position.z
	var delta_x = current_x - from_x
	var delta_z = current_z - from_z
	#print("player at : "+str(from_x)+","+str(from_z))
	#print("stone  at : "+str(current_x)+","+str(current_z))
	#print("deltas    : "+str(delta_x)+","+str(delta_z))
	
	start_x = current_x
	start_z = current_z
	end_x = start_x
	end_z = start_z
	if abs(delta_x) > abs(delta_z):
		# move in horizontal direction
		if delta_x > 0: end_x += 1
		else:           end_x -= 1
	else:
		# move in horizontal direction
		if delta_z > 0: end_z += 1
		else:           end_z -= 1
	
	if test_move(transform, Vector3(end_x-start_x, 0, end_z-start_z), false):
		# collision - cannot move
		# print("cannot move")
		pass
	else:
		print("moving from  "+str(start_x)+","+str(start_z) + " to " +str(end_x)+","+str(end_z))
		to_delta = 1.0
	moving = false

var parent = null
func set_parent(level_parent):
	parent = level_parent
