extends KinematicBody

export(String, "", "p1", "p2") var player
export (String) var playerName

onready var playerAnimation: AnimationPlayer  =  $Orientation/Toad_Toadette/AnimationPlayer

# player states
enum STATE {
	IDLE, # on ground
	WALK, # on ground
	WIN # on the ground
}
var playerStateOld = STATE.IDLE
var playerState = STATE.IDLE
var Pushing_Stone: Spatial = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var __ = playerAnimation.connect("animation_finished", self, "animation_finished")
	playerAnimation.get_animation("idle").set_loop(true)
	playerAnimation.get_animation("walk").set_loop(true)
	playerAnimation.get_animation("win").set_loop(false)
	playerAnimation.play("idle")
	if player == "p1":
		$Orientation/Toad_Toadette/Armature/Skeleton/TOAD.visible = false
	else:
		$Orientation/Toad_Toadette/Armature/Skeleton/TOADETTE.visible = false
	playerState = STATE.IDLE


var rotating_delta:float = -1

func _physics_process(delta):
	if playerState == STATE.WIN:
		updateAnimation()
		return
	if rotating_delta > 0:
		rotating_delta -= delta 
		$Orientation.transform = Transform.IDENTITY
		$Orientation.rotate_y(rotating_delta * 3 * PI)
		playerState = STATE.WALK
		if rotating_delta < 0: 
			playerState = STATE.WIN
		updateAnimation()
		return
		
	var speed : float = 1.0
	var direction = Vector3.ZERO
	playerState = STATE.IDLE

	if Input.is_action_pressed(player +"_up"):
		direction += Vector3(0,0,-1)
	if Input.is_action_pressed(player +"_down"):
		direction += Vector3(0,0,1)
	if Input.is_action_pressed(player +"_left"):
		direction += Vector3(-1,0,0)
	if Input.is_action_pressed(player +"_right"):
		direction += Vector3(1,0,0)

	direction = direction.normalized()
	if direction.length() > 0 :
		playerState = STATE.WALK
		$Orientation.transform = Transform.IDENTITY
		$Orientation.rotate_y(atan2(direction.x, direction.z))
	
	var velocity = direction * speed + Vector3(0,-0.4,0)
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# if fall off - keep on zero
	if transform.origin.y < 0:
		transform.origin.y = 0
	# set animation
	updateAnimation()
	
	if Input.is_action_just_pressed(player +"_A") :
		# print("try push object "+str(Pushing_Stone != null))
		if Pushing_Stone != null:
			Pushing_Stone.push_stone(transform.origin)
			#Pushing_Stone = null


func updateAnimation():
	if(playerStateOld != playerState):
		playerStateOld = playerState
		match playerState:
			STATE.IDLE: 
				playerAnimation.play("idle")
			STATE.WALK:
				playerAnimation.play("walk", -1, 1.6)
			STATE.WIN:
				playerAnimation.play("win")


func animation_finished(anim_name : String):
	if "win" == anim_name:
		return
	playerState = STATE.IDLE
	updateAnimation()

func win():
	rotating_delta = 1.5

func _on_Area_body_entered(body):
	if Pushing_Stone == null and body.has_method("push_stone"):
		Pushing_Stone = body


func _on_Area_body_exited(body):
	if  Pushing_Stone == body:
		Pushing_Stone = null
