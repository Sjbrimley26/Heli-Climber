extends "res://characters/enemies/Flyer.gd"

var Bullet = preload("res://characters/enemies/projectiles/Heli_Bullet.tscn")
var sound = preload("res://sounds/heli_drone_blast.wav")

func _init():
	ACCELERATION = 7
	MAX_HEALTH = 15.0
	MAX_SPEED = 260
	set_meta("enemy", "drone")
	
func _physics_process(_delta):
	if target != null:
		var spot = target.global_position - self.global_position
		$head/arm_l.rotation = spot.angle() - 90
		$head/arm_r.rotation = spot.angle() - 90
		
	match current_state:
		STATE_ATTACKING:
			# dual blasters
			var bullet_l = Bullet.instance()
			var bullet_r = Bullet.instance()
			bullet_l.set_meta("origin", "drone")
			bullet_r.set_meta("origin", "drone")
			get_parent().add_child(bullet_l)
			get_parent().add_child(bullet_r)
			var dir = target.global_position - self.global_position
			var angle = dir.angle()
			bullet_l.start_at(angle, $head/arm_l/end.get_global_position())
			bullet_r.start_at(angle, $head/arm_r/end.get_global_position())
			# reload
			reloading = FIRE_RATE
			current_state = STATE_CHASING
			var splayer = AudioStreamPlayer2D.new()
			splayer.stream = sound
			var _err = splayer.connect("finished", splayer, "queue_free")
			add_child(splayer)
			splayer.play()
