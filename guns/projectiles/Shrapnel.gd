extends "res://guns/projectiles/Bullet.gd"
signal trigger_aoe()
var prev_position

func _init():
	speed = 800
	set_damage(7)
	affected_by_gravity = true

func _ready():
	prev_position = get_global_position()
	$AOE.init(3)

func adjust_angle():
	var curr_position = get_global_position()
	var pnt = prev_position - curr_position
	set_rotation(pnt.angle() + 46)
	prev_position = curr_position
	
func on_collide(_body):
	set_physics_process(false)
	vel = Vector2()
	$Sprite.visible = false
	$CollisionShape2D.set_disabled(true)
	$AnimatedSprite.visible = true
	$AnimatedSprite.play()
	emit_signal("trigger_aoe")
	var _err = $AnimatedSprite.connect("animation_finished", self, "queue_free")
