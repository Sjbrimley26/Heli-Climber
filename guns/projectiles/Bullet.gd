extends KinematicBody2D

const GRAVITY = 20 

var vel = Vector2()
var speed = 1000
var damage = 1
var affected_by_gravity = false

func set_damage(x):
	damage = x

func on_collide():
	queue_free()

func start_at(dir, pos):
	set_rotation(dir)
	set_global_position(pos)
	vel = Vector2(speed, 0).rotated(dir)
	
func _init():
	set_meta('type', 'projectile')
	
func fall():
	if affected_by_gravity:
		vel.y += GRAVITY
		
func adjust_angle():
	pass
	
func _physics_process(delta):
	fall()
	adjust_angle()
	var collision = move_and_collide(vel * delta)
	if collision:
		var hit = collision.get_collider()
		if hit.has_method("on_collision"):
			hit.on_collision(self)
		# just delete itself
		on_collide()
