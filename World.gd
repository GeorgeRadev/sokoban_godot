extends Spatial

const Levels = preload("res://Levels.gd")
var levels = Array()
var current_level = 0
var levelContainer:Spatial = null
var current_level_win: bool = false
var current_level_targets = Array()
var current_level_stones = Array()
var level_changed = false

var Border = preload("res://Border.tscn")
var Ground = preload("res://Ground.tscn")
var Target = preload("res://Target.tscn")
var Stone = preload("res://Stone.tscn")

var Player = preload("res://Player.tscn")
var Fireworks = preload("res://Fireworks.tscn")
var P1:KinematicBody
var P2:KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var L = Levels.new();
	L.load_levels(levels)
	if len(levels) <= 0 : get_tree().quit()
	randomize()
	OS.window_fullscreen = true
	render_level(current_level)


func next_level():
	current_level +=1
	if current_level >=len(levels): current_level = 0
	level_changed = true


func prev_level():
	current_level -=1
	if current_level < 0: current_level = 0
	level_changed = true

func _process(_delta):
	if Input.is_action_just_released("NEXT_LEVEL"): next_level()
	elif Input.is_action_just_released("PREVIOUS_LEVEL"): prev_level()
	
	if level_changed:
		render_level(current_level)
	var dist = (P1.transform.origin - P2.transform.origin).length()/1.5
	$CameraPoint.transform.origin = 0.5 * P1.transform.origin + 0.5 * P2.transform.origin
	$CameraPoint/Camera.transform.origin = Vector3(0, 2 + dist, 2+dist)

func render_level(selected_level):
	level_changed = false
	var oldLevelContainer = levelContainer
	# create level object container
	levelContainer = Spatial.new()
	add_child(levelContainer)
	
	# delete old level elements
	if oldLevelContainer != null:
		remove_child(oldLevelContainer)
		oldLevelContainer.queue_free()
	
	var level = levels[selected_level]
	var z = -1
	var players_x=0
	var players_z=0
	current_level_targets = Array()
	current_level_stones = Array()
	
	for row in level:
		z+=1
		var x = -1
		var has_border = false
		for c in row.rstrip(' ').to_ascii():
			x+=1
			if c == 0x23 :
				# border
				var border = Border.instance()
				border.transform.origin = Vector3(x, 0, z)
				levelContainer.add_child(border)
				has_border = true
				
			
			if c == 0x40 or c==0x2b:
				# players
				players_x = x
				players_z = z
				
			if c == 0x24 or c==0x2a:
				# stone
				var stone = Stone.instance()
				stone.transform.origin = Vector3(x, 0, z)
				levelContainer.add_child(stone)
				current_level_stones.append(stone)
				
			if c == 0x2a or c==0x2b or c== 0x2e :
				# target
				var target = Target.instance()
				target.transform.origin = Vector3(x, 0, z)
				current_level_targets.append(target.transform.origin)
				levelContainer.add_child(target)
			else:
				if has_border:
					# ground
					var ground = Ground.instance()
					ground.transform.origin = Vector3(x, 0, z)
					levelContainer.add_child(ground)
	
	for stone in current_level_stones:
		stone.set_parent(self)
	# add player 1
	P1 = Player.instance()
	P1.transform.origin = Vector3(players_x +0.2, 0.1, players_z + 0.2)
	P1.player = "p1"
	P1.playerName = "TOADETTE"
	levelContainer.add_child(P1)
	# add player 2
	P2 = Player.instance()
	P2.transform.origin = Vector3(players_x - 0.2, 0.1, players_z - 0.2)
	P2.player = "p2"
	P2.playerName = "TOAD"
	levelContainer.add_child(P2)
	
	current_level_win= false

func stone_moved():
	for stone in current_level_stones:
		var in_place = false
		for target in current_level_targets:
			var distv:Vector3 = (stone.transform.origin - target)
			var dist = distv.length()
			if dist < 0.2: 
				in_place = true
				break
		if not in_place: return
	print("win")
	current_level_win = true
	#add fireworks
	for _i in range(6):
		var F = Fireworks.instance()
		F.transform.origin = $CameraPoint.transform.origin + Vector3((randf()-0.5)*3, 2+ (randf()-0.5)*2, -1-randf()*3)
		levelContainer.add_child(F)
	P1.win()
	P2.win()
	yield(get_tree().create_timer(5), "timeout")
	next_level()
