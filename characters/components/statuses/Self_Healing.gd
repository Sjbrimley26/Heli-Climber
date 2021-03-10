extends Node

export var HEAL_AMOUNT = 1.0
export var HEAL_RATE = 5.0
var cooldown = 5

signal trigger()

func init(amt, rate = 5.0):
	HEAL_AMOUNT = amt
	HEAL_RATE = rate

# MUST be a sibling of HealthBar
func _ready():
	var _err = connect("trigger", self, "heal", [HEAL_AMOUNT])
	
func heal(x):
	get_parent().get_node("HealthBar").adjust_health(x)
	
func _physics_process(_delta):
	cooldown -= 0.1
	if cooldown <= 0:
		cooldown = HEAL_RATE
		emit_signal("trigger")
