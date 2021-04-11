extends Area2D

var Bullet = preload("res://guns/projectiles/Bullet.gd")

export var damage = 5
export var knockback = 900
var origin: String

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = get_parent().connect("trigger_aoe", self, "explode")
	
func init(dmg):
	damage = dmg
	
func set_origin(name: String):
	origin = name
	
func explode():
	var explosion = Bullet.new()
	explosion.set_damage(damage)
	if origin != "":
		explosion.set_meta("origin", origin)
	for enemy in get_overlapping_bodies():
		if enemy.has_method("on_collision"):
			enemy.on_collision(explosion)
		if "velocity" in enemy:
			enemy.velocity += (enemy.global_position - global_position).normalized() * knockback
	explosion.queue_free()
