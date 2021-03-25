extends "res://characters/enemies/Enemy.gd"

const FIRE_RATE = 4
const FIRE_RANGE = 300
# https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-collision-avoidance--gamedev-7777
const SIGHT_RANGE = 100
const MAX_AVOID_FORCE = 6
const SEP_FORCE = 6

enum {STATE_IDLE, STATE_CHASING, STATE_ATTACKING}

var Bullet = preload("res://characters/enemies/projectiles/Heli_Bullet.tscn")
var sound = preload("res://sounds/heli_drone_blast.wav")

var velocity = Vector2()
var current_state = STATE_IDLE
var reloading = 0


func _init():
	ACCELERATION = 7
	MAX_HEALTH = 15.0
	MAX_SPEED = 260
	
	
func _physics_process(_delta):
	reloading -= 0.1
	if target != null:
		var spot = target.global_position - self.global_position
		$head/arm_l.rotation = spot.angle() - 90
		$head/arm_r.rotation = spot.angle() - 90
		
	match current_state:
		STATE_IDLE:
			# currently just sits until a target approaches
			if target != null:
				current_state = STATE_CHASING
		
		STATE_CHASING:
			var curr_x_speed = velocity.x
			var curr_y_speed = velocity.y
			var target_x_speed = curr_x_speed
			var target_y_speed = curr_y_speed
			var target_distance = target.global_position.distance_to(self.global_position)
			
			# check for line of sight
			var space_state = get_world_2d().direct_space_state
			var raycast = space_state.intersect_ray(global_position, target.global_position, [self])
			var hasLOS = raycast.has("collider") and raycast["collider"] == target
	
			# chase logic
			if target_distance > FIRE_RANGE or not hasLOS:
				if target.global_position.x < self.global_position.x:
					if curr_x_speed > -MAX_SPEED:
						target_x_speed -= ACCELERATION
				if target.global_position.x > self.global_position.x:
					if curr_x_speed < MAX_SPEED:
						target_x_speed += ACCELERATION

				if target.global_position.y - 20 < self.global_position.y:
					if curr_y_speed > -MAX_SPEED:
						target_y_speed -= ACCELERATION
				if target.global_position.y - 20 > self.global_position.y:
					if curr_y_speed < MAX_SPEED:
						target_y_speed += ACCELERATION
			
			var target_speed = Vector2(target_x_speed, target_y_speed)
			
			# collision avoidance
			if raycast.has("collider") and raycast["collider"] != target:
				var ahead = global_position + target_speed.normalized() * SIGHT_RANGE
				var avoidance = ahead - raycast["collider"].global_position
				avoidance = avoidance.normalized() * MAX_AVOID_FORCE
				target_speed = target_speed + avoidance
				
			# stop when in range
			if target_distance <= FIRE_RANGE and hasLOS:
				var target_location = global_position + target_speed
				
				var next_dist = target_location.distance_to(target.global_position)
				if next_dist >= FIRE_RANGE:
					target_speed = Vector2(0,0) # this causes a complete stop
					#target_speed.x *= 0.8
					#target_speed.y *= 0.8
					#if target_speed.length() <= 0.02:
						#target_speed = Vector2(0, 0)
					# this should cause a gradual slowdown
					
			# separation
			var neighbor_count = 0
			var sep_speed = target_speed
			for neighbor in $NeighborArea.get_overlapping_bodies():
				neighbor_count += 1
				sep_speed.x += (neighbor.global_position.x - global_position.x)
				sep_speed.y += (neighbor.global_position.y - global_position.y)
				
			if neighbor_count != 0:
				sep_speed.x /= neighbor_count
				sep_speed.y /= neighbor_count
				
			sep_speed.x *= -1
			sep_speed.y *= -1
			sep_speed = sep_speed.normalized() * SEP_FORCE
			target_speed += sep_speed
				
			# movement
			velocity = move_and_slide(target_speed, Vector2.UP)
			
			# check if shooting is a good idea
			if reloading <= 0 and target_distance <= FIRE_RANGE and hasLOS:
				current_state = STATE_ATTACKING
				
		STATE_ATTACKING:
			# dual blasters
			var bullet_l = Bullet.instance()
			var bullet_r = Bullet.instance()
			get_parent().add_child(bullet_l)
			get_parent().add_child(bullet_r)
			var dir = target.global_position - self.global_position
			var angle = dir.angle()
			bullet_l.start_at(angle, $head/arm_l/end.get_global_position())
			bullet_r.start_at(angle, $head/arm_r/end.get_global_position())
			# reload
			reloading = FIRE_RATE
			current_state = STATE_CHASING
			var splayer = AudioStreamPlayer.new()
			splayer.stream = sound
			var _err = splayer.connect("finished", splayer, "queue_free")
			add_child(splayer)
			splayer.play()
