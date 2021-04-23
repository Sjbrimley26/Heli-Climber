extends "res://guns/Gun.gd"


var bullet = preload("res://guns/projectiles/LauncherBullet.tscn")
var sound = preload("res://sounds/rocket.wav")
var seeker = preload("res://guns/projectiles/SeekerBullet.tscn")

func _play_sound():
	var splayer = AudioStreamPlayer.new()
	splayer.stream = sound
	var _err = splayer.connect("finished", splayer, "queue_free")
	add_child(splayer)
	splayer.play()

func shoot_bullet(dir):
	var bullet_instance = bullet.instance()
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle(), $Muzzle.get_global_position())
	_play_sound()
	Global.ammo[Global.LAUNCHER] -= 1
	
func shoot_ohm(dir):
	var bullet_instance = seeker.instance()
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle(), $Muzzle.get_global_position())
	_play_sound()
	Global.ammo[Global.LAUNCHER] -= 1
