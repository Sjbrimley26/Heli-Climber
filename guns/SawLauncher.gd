extends "res://guns/Gun.gd"

var saw = preload("res://guns/projectiles/MeleeSaw.tscn")
var bullet = preload("res://guns/projectiles/SawBlade.tscn")
var sound = preload("res://sounds/saw_running.wav")

const SAW_RELOAD_TIME := 2.0

# TODO: BUG FIX
# when the player shoots a saw towards the ground at about a 45 degree angle the blade can get stuck there

signal trigger_aoe()

var has_saw = true
var sound_player = null

func _reload(timer):
	has_saw = true
	var new_saw = saw.instance()
	$Muzzle.add_child(new_saw)
	timer.queue_free()
	
func _end_sound():
	sound_player.queue_free()
	sound_player = null

func fire(dir):
	if not has_saw:
		return
	$AnimationPlayer.play("fire", -1, 2)
	var overlapping_floor = null
	var targets_in_melee_range = []
	var all_overlaps = $Muzzle/Saw.get_overlapping_bodies()
	for body in all_overlaps:
		if body.has_meta("type"):
			var type = body.get_meta("type")
			if type == "enemy" or type == "prop":
				targets_in_melee_range.append(body)
			else:
				overlapping_floor = body
	
	if targets_in_melee_range.size() > 0:
		emit_signal("trigger_aoe")
		if sound_player == null:
			sound_player = AudioStreamPlayer.new()
			sound_player.stream = sound
			var _err2 = sound_player.connect("finished", self, "_end_sound")
			add_child(sound_player)
			sound_player.play()
		return
	
	if sound_player != null:
		_end_sound()
	
	Global.ammo[Global.SAW] -= 1
	var bullet_instance = bullet.instance()
	get_parent().get_parent().add_child(bullet_instance)
	var start_location = $Muzzle.get_global_position()
	if overlapping_floor:
		var shift = start_location - overlapping_floor.global_position
		start_location += shift * 1.5 # this fixed most of the issue, maybe if I increase the amount?
	
	bullet_instance.start_at(dir.angle(), start_location)
	bullet_instance.get_node("AnimationPlayer").play("default")
	has_saw = false
	$Muzzle/Saw.queue_free()
	var timer = Timer.new()
	timer.set_wait_time(SAW_RELOAD_TIME)
	var _err = timer.connect("timeout", self, "_reload", [timer])
	add_child(timer)
	timer.start()
	
func shoot_ohm(dir):
	if not has_saw:
		return
	var overlapping_floor = null
	var all_overlaps = $Muzzle/Saw.get_overlapping_bodies()
	for body in all_overlaps:
		if body.has_meta("type"):
			var type = body.get_meta("type")
			if type == "enemy" or type == "prop":
				continue
			else:
				overlapping_floor = body
	Global.ammo[Global.SAW] -= 1
	var bullet_instance = bullet.instance()
	get_parent().get_parent().add_child(bullet_instance)
	var start_location = $Muzzle.get_global_position()
	if overlapping_floor:
		var shift = start_location - overlapping_floor.global_position
		start_location += shift * 1.5 # this fixed most of the issue, maybe if I increase the amount?
	
	bullet_instance.speed = 2000
	bullet_instance.start_at(dir.angle(), start_location)
	bullet_instance.get_node("AnimationPlayer").play("default")
	has_saw = false
	$Muzzle/Saw.queue_free()
	var timer = Timer.new()
	timer.set_wait_time(SAW_RELOAD_TIME)
	var _err = timer.connect("timeout", self, "_reload", [timer])
	add_child(timer)
	timer.start()
