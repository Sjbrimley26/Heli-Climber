extends "res://guns/Gun.gd"


var bullet = preload("res://guns/projectiles/LauncherBullet.tscn")
var sound = preload("res://sounds/rocket.wav")

func shoot_bullet(dir):
	var bullet_instance = bullet.instance()
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle(), $Muzzle.get_global_position())
	var splayer = AudioStreamPlayer.new()
	splayer.stream = sound
	var _err = splayer.connect("finished", splayer, "queue_free")
	add_child(splayer)
	splayer.play()
