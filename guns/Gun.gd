extends Node

func shoot_bullet(_dir):
	pass

func fire(dir):
	$AnimationPlayer.play("fire", -1)
	shoot_bullet(dir)

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = get_parent().connect("fire", self, "fire")
