extends KinematicBody2D

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
const PUSHBACK_SPEED = 400

onready var stats = $Stats

var knockback = Vector2.ZERO
const KNOCKBACK_FRICTION = 200

onready var deathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
onready var deathFx = deathEffect.instance()
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

export(float) var InvincibleTimer = 0.3


enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE
var velocity = Vector2.ZERO

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	handle_knockback(delta)
	
	if playerDetectionZone.can_see_player():
		state = CHASE
	
	match state:
		IDLE:
			idle_state(delta)
		WANDER:
			wander_state(delta)
		CHASE:
			chase_state(delta)

	check_for_soft_collision(delta)
	velocity = move_and_slide(velocity)

func handle_knockback(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)

func check_for_soft_collision(delta):
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * PUSHBACK_SPEED
	
func chase_state(delta):
	var player = playerDetectionZone.player
	if player != null:
		move_to(player.global_position, delta)
	else:
		state = IDLE

func wander_state(delta):
	seek_player()
	check_for_new_state()
	move_to(wanderController.target_position, delta)
	
	var distance = global_position.distance_to(wanderController.target_position)
	if distance < 5:
		pick_random_state([IDLE, WANDER])

func idle_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	seek_player()
	check_for_new_state()
	
func move_to(other, delta):
	var direction = global_position.direction_to(other)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func check_for_new_state():
	if wanderController.get_time_left() == 0:
		state = pick_random_state([IDLE, WANDER])
		wanderController.start_wander_timer(rand_range(1, 3))

func _on_HurtBox_area_entered(area):
	knockback = area.knockback_vector * 120
	$Stats.hp = ($Stats.hp - 1)
	hurtbox.start_invincibility(InvincibleTimer)
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	deathFx.position = position
	get_parent().add_child(deathFx)


func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("End")
