extends "res://characters/enemies/Flyer.gd"


export var Bullet: PackedScene
export var sound: AudioStream

func _init():
	ACCELERATION = 4
	SIGHT_RANGE = 50
	MAX_HEALTH = 5.0
	MAX_SPEED = 320
	FIRE_RATE = 5
	FIRE_RANGE = 150
	set_meta("enemy", "hoverbot")
	
func die():
	$Light2D.queue_free()
	.die()
	
func _physics_process(_delta):
	
	if velocity.x > 0:
		$body.flip_h = true
	else:
		$body.flip_h = false
		
	match current_state:
		STATE_ATTACKING:
			# dual blasters
			var bullet = Bullet.instance()
			bullet.set_meta("origin", "hoverbot")
			get_parent().add_child(bullet)
			var dir = target.global_position - self.global_position
			var angle = dir.angle()
			bullet.start_at(angle, global_position)
			# reload
			reloading = FIRE_RATE
			current_state = STATE_CHASING
			var splayer = AudioStreamPlayer2D.new()
			splayer.stream = sound
			var _err = splayer.connect("finished", splayer, "queue_free")
			add_child(splayer)
			splayer.play()
