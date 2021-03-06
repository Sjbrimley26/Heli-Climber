extends "res://characters/enemies/Enemy.gd"

var Bullet = preload("res://guns/projectiles/Bullet.gd")

const JUMP = -900
const BITE_DAMAGE = 10

func is_between (toTest, min_val, max_val):
	if toTest >= min_val and toTest <= max_val:
		return true
	return false

func _init():
	MAX_SPEED = 320
	ACCELERATION = 10
	MAX_HEALTH = 30.0
	set_meta("enemy", "runner")
	affected_by_gravity = true
	
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
	chomp.set_meta("origin", "runner")
	for enemy in $Bite.get_overlapping_bodies():
		if enemy.has_method("on_collision"):
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
	$Light2D.queue_free()
	.die()
	
func _physics_process(_delta):
	match current_state:
		
		STATE_CHASING:
			var curr_speed = velocity.x
			var target_speed = curr_speed
	
			if target.global_position.x < self.global_position.x:
				if curr_speed > -MAX_SPEED:
					target_speed -= ACCELERATION
			if target.global_position.x > self.global_position.x:
				if curr_speed < MAX_SPEED:
					target_speed += ACCELERATION
			
			var x_dist = abs(self.global_position.x - target.global_position.x)
			var target_has_high_ground = target.global_position.y < self.global_position.y - 50
					
			# works okay, just starts leapiing towards the target when close
			if is_between(x_dist, 50, 200) and (target_has_high_ground) and is_on_floor():
				velocity.y = JUMP
			
			if not target_has_high_ground and is_on_floor() and is_on_wall():
				velocity.y = -600 # mini jump over stairs/barrels
				
			velocity.x = target_speed
			velocity.y = velocity.y + GRAVITY # fall
			velocity = move_and_slide(velocity, Vector2.UP)
			
			# walking animation
			if target.global_position.x < self.global_position.x:
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
