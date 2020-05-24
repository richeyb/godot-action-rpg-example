extends Node

export(int) var max_hp = 1 setget set_max_hp
export(int) var hp = max_hp setget set_hp

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func reset():
	self.hp = max_hp

func set_hp(value):
	hp = min(value, max_hp)
	emit_signal("health_changed", hp)
	if hp <= 0:
		emit_signal("no_health")

func set_max_hp(value):
	max_hp = value
	self.hp = min(hp, max_hp)
	emit_signal("max_health_changed", max_hp)
