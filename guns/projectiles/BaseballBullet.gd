extends "res://guns/projectiles/Bullet.gd"

var sound = preload("res://sounds/explosion_2.wav")

var prev_position

signal trigger_aoe()

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

func on_collide():
	set_physics_process(false)
	vel = Vector2()
	$CollisionShape2D.set_disabled(true)
	$Tail.visible = false
	$AnimatedSprite.set_speed_scale(1.5)
	$AnimatedSprite.play("explode")
	emit_signal("trigger_aoe")
	var _err = $AnimatedSprite.connect("animation_finished", self, "queue_free")
	$AnimatedSprite.translate(Vector2(0, 22)) # the explosion animation is centered whereas the baseball itself is at the bottom
	var splayer = AudioStreamPlayer.new()
	splayer.stream = sound
	var _err2 = splayer.connect("finished", splayer, "queue_free")
	add_child(splayer)
	splayer.play()
