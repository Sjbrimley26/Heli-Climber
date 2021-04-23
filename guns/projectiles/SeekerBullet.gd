extends "res://guns/projectiles/LauncherBullet.gd"

#const SIGHT = 300
var target

func _physics_process(_delta):
	if $Detection.get_overlapping_bodies().size() == 0:
		return
	var potentialTargets = $Detection.get_overlapping_bodies()
	var minDst = 10000000
	var space_state = get_world_2d().direct_space_state
	for t in potentialTargets:
		var dst = global_position.distance_to(t.global_position)
		if dst < 50:
			target = t
			break
		var raycast = space_state.intersect_ray(global_position, t.global_position, [self])
		var hasLOS = raycast.has("collider") and raycast["collider"] == t
		if not hasLOS:
			continue
		if dst < minDst:
			minDst = dst
			target = t
	if not target:
		return
	var dir = target.global_position - global_position
	set_rotation(dir.angle())
	vel = vel.normalized() * 250 + dir.normalized() * 50
	#vel = vel.rotated(dir.angle())
