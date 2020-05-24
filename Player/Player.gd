extends KinematicBody2D

var velocity = Vector2.ZERO
const MAX_SPEED = 80
const ACCELERATION = 500
const FRICTION = 500
const ROLL_SPEED = 125

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $HurtBox

onready var audioPlayer = $AudioStreamPlayer
onready var hurtSound = preload("res://Music and Sounds/Hurt.wav")

onready var blinkAnimationPlayer = $BlinkAnimationPlayer

export(float) var InvincibleTimer = 0.6;

enum {
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE
var roll_vector = Vector2.DOWN

var stats = PlayerStats

func _ready():
	randomize()
	stats.reset()
	stats.connect("no_health", self, "no_health")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("roll"):
		state = ROLL

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	state = MOVE
	
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func move():
	move_and_slide(velocity)
	
func no_health():
	queue_free()

func _on_HurtBox_area_entered(area):
	if state == ROLL:
		return
	audioPlayer.stream = hurtSound
	audioPlayer.play()
	stats.hp = (stats.hp - area.damage)
	hurtbox.start_invincibility(InvincibleTimer)
	hurtbox.create_hit_effect()

func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("End")


