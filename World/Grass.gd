extends Node2D

onready var grassEffect = preload("res://Effects/GrassEffect.tscn")
onready var fx = grassEffect.instance()

func destroy_grass():
	fx.position = position
	get_parent().add_child(fx)
	queue_free()

func _on_HurtBox_area_entered(area):
	destroy_grass()
