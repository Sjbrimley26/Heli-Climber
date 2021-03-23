extends Area2D

const GRAVITY = 20 

var vel = Vector2()
var speed = 1000
var damage = 1
var affected_by_gravity = false

func set_damage(x):
	damage = x

func on_collide(body):
	if body.has_method("on_collision"):
			body.on_collision(self)
	queue_free()

func start_at(dir, pos):
	set_rotation(dir)
	set_global_position(pos)
	vel = Vector2(speed, 0).rotated(dir)
	
func _init():
	set_meta('type', 'projectile')
	
func _ready():
	var _err = connect("body_entered", self, "on_collide")
	
func fall():
	if affected_by_gravity:
		vel.y += GRAVITY
		
func adjust_angle():
	pass
	
func _physics_process(delta):
	fall()
	adjust_angle()
	set_position(position + vel * delta)
