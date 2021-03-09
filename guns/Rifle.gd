extends "res://guns/Gun.gd"


var bullet = preload("res://guns/projectiles/RifleBullet.tscn")

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func shoot_bullet(dir):
	var bullet_instance = bullet.instance()
	var splay = deg2rad(rng.randfn(0, 5))
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle() + splay, $Muzzle.get_global_position())
