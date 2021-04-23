extends KinematicBody2D


var vel = Vector2()
var speed = 800
var damage = 7
var prev_position

var shrapnel = preload("res://guns/projectiles/Shrapnel.tscn")

const GRAVITY = 20


signal trigger_aoe()

func _init():
	set_meta('type', 'projectile')
	
func _ready():
	prev_position = global_position

func start_at(dir, pos):
	set_rotation(dir)
	set_global_position(pos)
	vel = Vector2(speed, 0).rotated(dir)
	
func adjust_angle():
	var curr_position = get_global_position()
	var pnt = prev_position - curr_position
	set_rotation(pnt.angle() + 46)
	prev_position = curr_position
	
func _spawn_shrapnel(normal):
	for i in range(-2, 6, 1):
		var angle = normal.tangent().angle() + i * PI/4
		var s = shrapnel.instance()
		get_parent().get_parent().add_child(s)
		s.start_at(angle, global_position)
	
func on_collision():
	set_physics_process(false)
	vel = Vector2()
	$CollisionShape2D.set_disabled(true)
	$Tail.visible = false
	$AnimatedSprite.set_speed_scale(1.5)
	$AnimatedSprite.play("explode")
	emit_signal("trigger_aoe")
	var _err = $AnimatedSprite.connect("animation_finished", self, "queue_free")
	$AnimatedSprite.translate(Vector2(0, 22)) # the explosion animation is centered whereas the baseball itself is at the bottom
	$Light2D.visible = true
	var _err3 = get_tree().create_timer(0.3).connect("timeout", $Light2D, "queue_free")

func _physics_process(delta):
	adjust_angle()
	vel.y += GRAVITY
	var collision = move_and_collide(vel * delta)
	if collision:
		var hit = collision.get_collider()
		if hit.has_meta("type"):
			hit.on_collision(self)
		_spawn_shrapnel(collision.normal)
		on_collision()
