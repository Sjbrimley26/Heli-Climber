extends "res://guns/Gun.gd"

signal trigger_aoe()

func _start_block(dir):
	var _err = $AOE.connect("area_entered", self, "_deflect_bullet", [dir])
	
func _stop_block(timer):
	$AOE.disconnect("area_entered", self, "_deflect_bullet")
	timer.queue_free()
	
func _deflect_bullet(area, dir):
	if area.has_meta("type") and area.get_meta("type") == "projectile":
		area.vel = area.vel.reflect(dir.tangent().normalized())
		area.rotation = dir.angle()
		area.set_collision_mask_bit(2, true) # not working

func fire(dir):
	_start_block(dir)
	$AnimationPlayer.play("fire", -1, 1.5)
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_swing", [timer], CONNECT_ONESHOT)
	timer.set_wait_time(0.3)
	add_child(timer)
	timer.start()

func _swing(timer):
	emit_signal("trigger_aoe")
	timer.set_wait_time(0.1)
	timer.connect("timeout", self, "_stop_block", [timer], CONNECT_ONESHOT)
	timer.start()
	
