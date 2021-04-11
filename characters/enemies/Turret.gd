extends "res://characters/enemies/Enemy.gd"

export var Bullet: PackedScene
export var sound: AudioStream
export var FIRE_RATE := 1.0
var reloading = 0

func _init():
	MAX_HEALTH = 15.0
	set_meta("enemy", "turret")
	
func _ready():
	var _err = $Detection.connect("body_exited", self, "_lost_target")
	
func _physics_process(_delta):
	reloading -= 0.1
	
	var target_in_sight = false
	if target:
		target_in_sight = _is_target_in_sight()
		if target_in_sight:
			var spot = target.global_position - global_position
			$Barrel.rotation = spot.angle()
			$Line2D.visible = true
			$Line2D.set_point_position(1, $Barrel/Muzzle.global_position - target.global_position)
		else:
			$Line2D.visible = false

	match current_state:
		STATE_CHASING:
			# check for line of sight
			if target_in_sight && reloading <= 0:
				current_state = STATE_ATTACKING
		STATE_ATTACKING:
			var bullet = Bullet.instance()
			bullet.set_meta("origin", "turret")
			get_parent().add_child(bullet)
			var dir = target.global_position + Vector2(target.velocity.x / 2.5, 0) - self.global_position
			var angle = dir.angle()
			bullet.start_at(angle, $Barrel/Muzzle.global_position)
			# reload
			reloading = FIRE_RATE
			current_state = STATE_CHASING
			var splayer = AudioStreamPlayer2D.new()
			splayer.stream = sound
			var _err = splayer.connect("finished", splayer, "queue_free")
			add_child(splayer)
			splayer.play()
			$Barrel/Light2D.visible = true
			$Barrel/Flash.visible = true
			var timer = Timer.new()
			timer.set_wait_time(reloading / 8.0)
			var _err2 = timer.connect("timeout", self, "_end_flash", [timer], CONNECT_ONESHOT)
			add_child(timer)
			timer.start()
	
func _lost_target(body):
	if body == target:
		target = null
		current_state = STATE_IDLE
		$Line2D.visible = false

func die():
	$Barrel.visible = false
	$Base.visible = false
	.die()

func _end_flash(timer: Timer):
	$Barrel/Light2D.visible = false
	$Barrel/Flash.visible = false
	timer.queue_free()
