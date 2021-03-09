extends KinematicBody2D

var velocity = Vector2()
const ACCELERATION = 10
const MAX_SPEED = 320
const GRAVITY = 30
const MAX_HEALTH = 30.0
const JUMP = -900

enum {STATE_IDLE, STATE_CHASING, STATE_ATTACKING}

signal hp_changed(x)

var target
var current_state = STATE_IDLE

func _ready():
	set_meta("type", "enemy")
	var _err1 = $Detection.connect("body_entered", self, "enemy_detected")
	var _err2 = $HealthBar.connect("dead", self, "die")
	$HealthBar.set_max_health(MAX_HEALTH)
	var _err3 = $Detonation.connect("animation_finished", self, "queue_free")
	var _err4 = $AnimationPlayer.connect("animation_finished", self, "on_animation_end")
	# disable movement until it detects the player
	
func enemy_detected(body):
	if body.get_meta("type") == "player":
		target = body

func bite():
	$AnimationPlayer.play("bite", -1, 1.5)
	
func on_animation_end(name):
	if name == "bite":
		current_state = STATE_CHASING
	
func on_collision(body):
	if body.get_meta("type") == "projectile":
		emit_signal("hp_changed", -body.damage)
		

func die():
	$CollisionShape2D.set_deferred("disabled", true)
	$Detonation.visible = true
	$Detonation.playing = true
	$body.visible = false
	$HealthBar.visible = false
	$AnimationPlayer.stop()
	set_physics_process(false)
	pass
	
func _physics_process(_delta):
	match current_state:
		STATE_IDLE:
			# currently just sits until a target approaches
			if target != null:
				current_state = STATE_CHASING
			velocity.y = velocity.y + GRAVITY # fall
			velocity = move_and_slide(velocity, Vector2.UP)
		
		STATE_CHASING:
			var curr_speed = velocity.x
			var target_speed = curr_speed
	
			if target.position.x < self.position.x:
				if curr_speed > -MAX_SPEED:
					target_speed -= ACCELERATION
			if target.position.x > self.position.x:
				if curr_speed < MAX_SPEED:
					target_speed += ACCELERATION
					
			# works okay, just starts leapiing towards the target when close
			if abs(self.position.x - target.position.x) < 200 and target.position.y < self.position.y - 50 and is_on_floor():
				velocity.y = JUMP
				
			velocity.x = target_speed
			velocity.y = velocity.y + GRAVITY # fall
			velocity = move_and_slide(velocity, Vector2.UP)
			
			# walking animation
			if target.position.x < self.position.x:
				$AnimationPlayer.play("walk", -1, 1.5)
			else:
				$AnimationPlayer.play("walk-right", -1, 1.5)
	
			# check if anyone in attack range
			if $Bite.get_overlapping_bodies().size() != 0:
				current_state = STATE_ATTACKING
				
		STATE_ATTACKING:
			bite()
			velocity.y = velocity.y + GRAVITY # fall
			velocity = move_and_slide(velocity, Vector2.UP)
	
	
		
	
