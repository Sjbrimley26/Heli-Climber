extends "res://guns/Gun.gd"


var bullet = preload("res://guns/projectiles/BaseballBullet.tscn")

func shoot_bullet(dir):
	delayed(dir)
	Global.ammo[Global.BAT] -= 1
	

func delayed(dir):
	var bullet_instance = bullet.instance()
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle(), $Muzzle.get_global_position())
