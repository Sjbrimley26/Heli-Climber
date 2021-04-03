extends "res://guns/Gun.gd"


var bullet = preload("res://guns/projectiles/RifleBullet.tscn")
var sound = preload("res://sounds/rifle.wav")

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func shoot_bullet(dir):
	var bullet_instance = bullet.instance()
	var splay = deg2rad(rng.randfn(0, 5))
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle() + splay, $Muzzle.get_global_position())
	var splayer = AudioStreamPlayer.new()
	splayer.stream = sound
	var _err = splayer.connect("finished", splayer, "queue_free")
	add_child(splayer)
	splayer.play()
	Global.ammo[Global.RIFLE] -= 1
