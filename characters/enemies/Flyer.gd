extends "res://characters/enemies/Enemy.gd"

# requires a NeighborArea = a 2d with its mask set to enemies

export var FIRE_RATE = 7
export var FIRE_RANGE = 300
export var SIGHT_RANGE = 100
export var MAX_AVOID_FORCE = 6
export var SEP_FORCE = 6

var reloading = 0

func _physics_process(_delta):
	if reloading > 0:
		reloading -= 0.1
	
	match current_state:
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
