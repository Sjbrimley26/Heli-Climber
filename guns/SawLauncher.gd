extends "res://guns/Gun.gd"

var saw = preload("res://guns/projectiles/MeleeSaw.tscn")
var bullet = preload("res://guns/projectiles/SawBlade.tscn")

signal trigger_aoe()

var has_saw = true

func _reload(timer):
	has_saw = true
	var new_saw = saw.instance()
	$Muzzle.add_child(new_saw)
	timer.queue_free()

func fire(dir):
	if not has_saw:
		return
	$AnimationPlayer.play("fire", -1, 2)
	var targets_in_melee_range = []
	for body in $Muzzle/Saw.get_overlapping_bodies():
		if body.has_meta("type"):
			var type = body.get_meta("type")
			if type == "enemy" or type == "prop":
				targets_in_melee_range.append(body)
	if targets_in_melee_range.size() > 0:
		emit_signal("trigger_aoe")
		return
	
	var bullet_instance = bullet.instance()
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle(), $Muzzle.get_global_position())
	bullet_instance.get_node("AnimationPlayer").play("default")
	has_saw = false
	$Muzzle/Saw.queue_free()
	var timer = Timer.new()
	timer.set_wait_time(3)
	var _err = timer.connect("timeout", self, "_reload", [timer])
	add_child(timer)
	timer.start()
	
	
