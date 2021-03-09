extends "res://guns/Gun.gd"


var bullet = preload("res://guns/projectiles/BaseballBullet.tscn")

func shoot_bullet(dir):
	#var timer = Timer.new()
	#add_child(timer)
	#timer.set_one_shot(true)
	#timer.connect("timeout", self, "delayed", [dir])
	#timer.set_wait_time(0.3)
	#timer.start()
	delayed(dir)
	

func delayed(dir):
	var bullet_instance = bullet.instance()
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle(), $Muzzle.get_global_position())
