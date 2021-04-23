extends "res://guns/Gun.gd"


var bullet = preload("res://guns/projectiles/RifleBullet.tscn")
var sound = preload("res://sounds/rifle.wav")

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
func _play_sound():
	var splayer = AudioStreamPlayer.new()
	splayer.stream = sound
	var _err = splayer.connect("finished", splayer, "queue_free")
	add_child(splayer)
	splayer.play()

func shoot_bullet(dir):
	var bullet_instance = bullet.instance()
	var splay = deg2rad(rng.randfn(0, 5))
	get_parent().get_parent().add_child(bullet_instance)
	bullet_instance.start_at(dir.angle() + splay, $Muzzle.get_global_position())
	_play_sound()
	Global.ammo[Global.RIFLE] -= 1
	
func shoot_delayed():
	var dir = get_global_mouse_position() - get_parent().global_position
	var b = bullet.instance()
	get_parent().get_parent().add_child(b)
	b.start_at(dir.angle(), $Muzzle.global_position)
	_play_sound()
	
func shoot_ohm(_dir):
	for i in range (0, 11):
		var timer = Timer.new()
		timer.connect("timeout", self, "shoot_delayed")
		timer.connect("timeout", timer, "queue_free")
		add_child(timer)
		timer.start(i * 0.1)
	if Global.ammo[Global.RIFLE] < 5:
		Global.ammo[Global.RIFLE] = 0
	else:
		Global.ammo[Global.RIFLE] -= 5
