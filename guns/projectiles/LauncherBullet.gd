extends "res://guns/projectiles/Bullet.gd"

var explosion_sound = preload("res://sounds/explosion_1.wav")

signal trigger_aoe()

func _init():
	speed = 400
	set_damage(10)

func on_collide():
	var splayer = AudioStreamPlayer2D.new()
	splayer.stream = explosion_sound
	var _err2 = splayer.connect("finished", splayer, "queue_free")
	add_child(splayer)
	splayer.play()
	vel = Vector2()
	$CollisionShape2D.set_disabled(true)
	$AnimatedSprite.play("explode")
	var _err = $AnimatedSprite.connect("animation_finished", self, "queue_free")
	emit_signal("trigger_aoe")
	
