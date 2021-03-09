extends Node2D

const SLIDER_MAX = 100.0

var max_health
var current_health

signal dead

func set_health(x):
	current_health = x
	adjust_bar()
	
func adjust_health(amount):
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	if current_health <= 0:
		current_health = 0
		emit_signal("dead")
	adjust_bar()

func heal():
	current_health = max_health
	adjust_bar()

func damage(x):
	adjust_health(-x)
	
func set_max_health(x):
	max_health = x
	current_health = x
	adjust_bar()
	
func adjust_bar():
	var multiplier = SLIDER_MAX / max_health
	$TextureProgress.value = current_health * multiplier

func _ready():
	var _err = get_parent().connect("hp_changed", self, "adjust_health")

