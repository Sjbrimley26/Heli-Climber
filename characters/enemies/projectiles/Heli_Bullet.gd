extends "res://characters/enemies/projectiles/Area2DBullet.gd"

var collided = false

func _init():
	set_damage(5)

func on_collide(body):
	if collided:
		return
	collided = true
	if body.has_method("on_collision"):
			body.on_collision(self)
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite.play("explode")
	$AnimatedSprite.translate(Vector2(8, 0))
	var _err = $AnimatedSprite.connect("animation_finished", self, "queue_free")
