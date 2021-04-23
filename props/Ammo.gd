extends Node2D

enum {SWORD, PISTOL, RIFLE, LAUNCHER, BOLT_LAUNCHER, BAT, SAW}

const AMMO_TYPES = [
	RIFLE,
	LAUNCHER,
	BOLT_LAUNCHER,
	BAT,
	SAW
]

const CHANCES = [
	30,
	50,
	65,
	85,
	100
] # so 0 - 30, 31 - 50, 51 - 65...

var rng

export(int, 0, 4) var type: int
export var random = false

func _ready():
	if not random:
		_set_type(type)
		return
	rng = RandomNumberGenerator.new()
	rng.randomize()
	var set = false
	var d100 = rng.randi_range(1, 100)
	for i in range(0, CHANCES.size(), 1):
		if d100 <= CHANCES[i]:
			_set_type(i)
			set = true
			break
	
	if not set:
		print("how and why? " + String(d100))

func _set_type(t: int):
	$AnimatedSprite.frame = t
	var _err = $Area2D.connect("body_entered", self, "_give_ammo", [AMMO_TYPES[t]], CONNECT_ONESHOT)

func _give_ammo(_body: Player, weapon: int):
	var amount: int
	match weapon:
		RIFLE:
			amount = 30
		LAUNCHER:
			amount = 10
		BOLT_LAUNCHER:
			amount = 8
		BAT:
			amount = 15
		SAW:
			amount = 10
	Global.ammo[weapon] += amount
	queue_free()
