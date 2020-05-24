extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

onready var youDiedDisplay = $YouDied
onready var youDiedSoundEffect = $YouDiedPlayer

onready var gameOverTimer = $GameOverTimer

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 15
		
	if hearts <= 0:
		youDiedDisplay.visible = true
		youDiedSoundEffect.play()
		gameOverTimer.start()

func set_max_hearts(value):
	max_hearts = value
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 15

func _ready():
	self.max_hearts = PlayerStats.max_hp
	self.hearts = PlayerStats.hp
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")

func _on_GameOverTimer_timeout():
	Global.goto_title_screen()
