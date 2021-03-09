extends "res://guns/projectiles/Bullet.gd"

signal trigger_aoe()

func _init():
	speed = 400
	set_damage(10)

func on_collide():
	vel = Vector2()
	$CollisionShape2D.set_disabled(true)
	$AnimatedSprite.play("explode")
	var _err = $AnimatedSprite.connect("animation_finished", self, "queue_free")
	emit_signal("trigger_aoe")
	
