extends Area2D

onready var hitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false setget set_invincible

signal invincibility_started
signal invincibility_ended

onready var timer = $Timer
onready var collisionShape = $CollisionShape2D

func set_invincible(value):
	invincible = value
	if value:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	timer.start(duration)
	self.invincible = true

func create_hit_effect():
	var hitFx = hitEffect.instance()
	hitFx.position = position
	get_parent().add_child(hitFx)

func _on_Timer_timeout():
	self.invincible = false

func _on_HurtBox_invincibility_ended():
#	set_deferred("monitorable", true)
	collisionShape.set_deferred("disabled", false)

func _on_HurtBox_invincibility_started():
#	set_deferred("monitorable", false)
	collisionShape.set_deferred("disabled", true)
