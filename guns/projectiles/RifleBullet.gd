extends "res://guns/projectiles/Bullet.gd"


func _init():
	set_damage(3)

func on_collide():
	set_physics_process(false)
	$CollisionShape2D.set_disabled(true)
	$AnimatedSprite.play("explode")
	var _err = $AnimatedSprite.connect("animation_finished", self, "queue_free")
	$AnimatedSprite.translate(Vector2(8, 0))
