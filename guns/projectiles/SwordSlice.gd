extends "res://guns/projectiles/Bullet.gd"

func _init():
	set_damage(5)
	speed = 600
	
func on_collide(body):
	if body.has_meta("type") and body.get_meta("type") == "enemy":
		add_collision_exception_with(body)
	else:
		queue_free()
