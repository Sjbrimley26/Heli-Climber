extends "res://guns/Gun.gd"

signal trigger_aoe()

func fire(dir):
	$AnimationPlayer.play("fire", -1, 1.5)
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "swing", [timer])
	timer.set_wait_time(0.3)
	add_child(timer)
	timer.start()

func swing(timer):
	emit_signal("trigger_aoe")
	timer.queue_free()
