extends "res://characters/enemies/Enemy.gd"

var Bullet = preload("res://guns/projectiles/Bullet.gd")

const GRAVITY = 30
const JUMP = -900
const BITE_DAMAGE = 15

enum {STATE_IDLE, STATE_CHASING, STATE_ATTACKING}

var current_state = STATE_IDLE
var velocity = Vector2()

func is_between (toTest, min_val, max_val):
	if toTest >= min_val and toTest <= max_val:
		return true
	return false

func _init():
	MAX_SPEED = 320
	ACCELERATION = 10
	MAX_HEALTH = 30.0
	
var _is_biting = false

func bite():
	if _is_biting:
		return
	_is_biting = true
	$AnimationPlayer.play("bite", -1, 1.5)
	var _err = $Bite.connect("body_exited", self, "cancel_bite")
	var timer = Timer.new()
	timer.set_wait_time(0.5)
	var _err2 = timer.connect("timeout", self, "trigger_bite_damage", [timer], CONNECT_ONESHOT)
	add_child(timer)
	timer.start()
	
func trigger_bite_damage(timer):
	var chomp = Bullet.new()
	chomp.set_damage(BITE_DAMAGE)
	for enemy in $Bite.get_overlapping_bodies():
		enemy.on_collision(chomp)
	chomp.queue_free()
	timer.queue_free()

func cancel_bite(body):
	if body and body != target:
		return
	$AnimationPlayer.play("rest")
	_is_biting = false
	$Bite.disconnect("body_exited", self, "cancel_bite")
	$Bite/Sprite.visible = false
	current_state = STATE_CHASING

func on_animation_end(name):
	if name == "bite":
		cancel_bite(null)
		
func die():
	$Bite/Sprite.visible = false
	.die()
	
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
			
			var x_dist = abs(self.position.x - target.position.x)
			var target_has_high_ground = target.position.y < self.position.y - 50
					
			# works okay, just starts leapiing towards the target when close
			if is_between(x_dist, 50, 200) and (target_has_high_ground) and is_on_floor():
				velocity.y = JUMP
			
			if not target_has_high_ground and is_on_floor() and is_on_wall():
				velocity.y = -600 # mini jump over stairs/barrels
				
			velocity.x = target_speed
			velocity.y = velocity.y + GRAVITY # fall
			velocity = move_and_slide(velocity, Vector2.UP)
			
			# walking animation
			if target.position.x < self.position.x:
				$AnimationPlayer.play("walk", -1, 1.5)
			else:
				$AnimationPlayer.play("walk-right", -1, 1.5)
	
			# check if anyone in attack range
			var targets_in_range = $Bite.get_overlapping_bodies()
			if targets_in_range.has(target):
				current_state = STATE_ATTACKING
				
		STATE_ATTACKING:
			bite()
			velocity.y = velocity.y + GRAVITY # fall
			velocity = move_and_slide(velocity, Vector2.UP)
			velocity.x = lerp(velocity.x, 0, 0.1)
