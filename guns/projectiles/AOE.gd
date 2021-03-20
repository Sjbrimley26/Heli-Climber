extends Area2D

var Bullet = preload("res://guns/projectiles/Bullet.gd")

export var damage = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = get_parent().connect("trigger_aoe", self, "explode")
	
func init(dmg):
	damage = dmg
	
func explode():
	var explosion = Bullet.new()
	explosion.set_damage(damage)
	for enemy in get_overlapping_bodies():
		if enemy.has_method("on_collision"):
			enemy.on_collision(explosion)
	explosion.queue_free()
