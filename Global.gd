extends Node

var worldScene = "res://World.tscn"
var titleScreenScene = preload("res://TitleScreen.tscn")

var current_scene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_title_screen():
	call_deferred("_deferred_goto_scene", titleScreenScene)	
	
func goto_world_scene():
	var world = ResourceLoader.load(worldScene)
	call_deferred("_deferred_goto_scene", world)
	
func _deferred_goto_scene(scene):
	current_scene.free()
	current_scene = scene.instance()
	
	get_tree().get_root().add_child(current_scene)
