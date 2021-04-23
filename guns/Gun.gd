extends Node2D

func shoot_bullet(_dir):
	pass
	
func shoot_ohm(_dir):
	pass

func fire(dir):
	$AnimationPlayer.play("fire", -1)
	shoot_bullet(dir)
	
func ohm(dir):
	$AnimationPlayer.play("fire", -1)
	shoot_ohm(dir)
	get_parent().get_node("CanvasLayer/GUI").use_ohm()

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = get_parent().connect("fire", self, "fire")
	var _err2 = get_parent().connect("ohm", self, "ohm")
