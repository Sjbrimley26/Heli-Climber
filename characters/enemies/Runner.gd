extends "res://characters/enemies/Enemy.gd"

const GRAVITY = 30
const JUMP = -900

enum {STATE_IDLE, STATE_CHASING, STATE_ATTACKING}

var current_state = STATE_IDLE
var velocity = Vector2()


func _init():
	MAX_SPEED = 320
	ACCELERATION = 10
	MAX_HEALTH = 30.0


func bite():
	$AnimationPlayer.play("bite", -1, 1.5)
	

func on_animation_end(name):
	if name == "bite":
		current_state = STATE_CHASING

	
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
	
	
		
	
