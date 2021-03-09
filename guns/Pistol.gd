extends "res://guns/Gun.gd"

var bullet = preload("res://guns/projectiles/PistolBullet.tscn")

func shoot_bullet(dir):
	var bullet_instance = bullet.instance()
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle(), $Muzzle.get_global_position())
