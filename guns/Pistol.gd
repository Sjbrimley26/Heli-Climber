extends "res://guns/Gun.gd"

var bullet = preload("res://guns/projectiles/PistolBullet.tscn")
var sound = preload("res://sounds/pistol.wav")

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
	
func shoot_ohm(dir):
	for i in [-PI/16, -PI/32, 0, PI/32, PI/16]:
		_play_sound()
		var b = bullet.instance()
		get_parent().get_parent().add_child(b)
		b.start_at(dir.angle() + i, $Muzzle.global_position)
