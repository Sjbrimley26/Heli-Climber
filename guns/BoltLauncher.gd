extends "res://guns/Gun.gd"

var explosion = preload("res://guns/projectiles/BoltImpact.tscn")
var bullet = preload("res://guns/projectiles/Bullet.gd")
var sound = preload("res://sounds/bolt.wav")

func fire(dir):
	$AnimationPlayer.play("fire", -1, 1.8)
	shoot_bullet(dir)

func shoot_bullet(dir):
	var rc = $RayCast2D
	rc.force_raycast_update()
	if not rc.is_colliding():
		return
	var impact = bullet.new()
	impact.set_damage(15)
	var hit = rc.get_collider()
	if hit.has_method("on_collision"):
		hit.on_collision(impact)
	var kaboom = explosion.instance()
	get_parent().get_parent().add_child(kaboom)
	var sprite = kaboom.get_node("AnimatedSprite")
	sprite.connect("animation_finished", kaboom, "queue_free")
	kaboom.global_transform.origin = rc.get_collision_point()
	var angle = dir.angle()
	kaboom.rotate(angle - PI/2)
	sprite.playing = true
	var splayer = AudioStreamPlayer.new()
	splayer.stream = sound
	var _err = splayer.connect("finished", splayer, "queue_free")
	add_child(splayer)
	splayer.play()
