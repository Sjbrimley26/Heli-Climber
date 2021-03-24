extends KinematicBody2D


var vel = Vector2()
var speed = 1000
var damage = 5
var recently_hit_enemies = []

func on_collide():
	queue_free()

func start_at(dir, pos):
	set_rotation(dir)
	set_global_position(pos)
	vel = Vector2(speed, 0).rotated(dir)
	
func _rebound(normal):
	for e in recently_hit_enemies:
		if e != null:
			remove_collision_exception_with(e)
	recently_hit_enemies = []
	vel = vel.reflect(normal.tangent())
	
func _init():
	set_meta('type', 'projectile')

func _ready():
	var lifespan = Timer.new()
	lifespan.set_wait_time(4)
	var _err = lifespan.connect("timeout", self, "queue_free")
	add_child(lifespan)
	lifespan.start()
	
func _physics_process(delta):
	var collision = move_and_collide(vel * delta)
	if collision:
		var hit = collision.get_collider()
		if hit.has_meta("type"):
			var type = hit.get_meta("type")
			if type == "prop":
				_rebound(collision.normal)
				hit.on_collision(self)
			if type == "enemy" and not hit in recently_hit_enemies:
				hit.on_collision(self)
				recently_hit_enemies.append(hit)
				add_collision_exception_with(hit)
			return
		_rebound(collision.normal)
