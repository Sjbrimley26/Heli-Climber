extends StaticBody2D

signal trigger_aoe()
const MAX_HITS = 3
var hit_count = 0

func on_collision(body):
	if body.has_meta("type") and body.get_meta("type") == "projectile":
		if hit_count == MAX_HITS:
			explode()
		hit_count += 1
		
func explode():
	$AnimatedSprite.play("explode")
	emit_signal("trigger_aoe")
	$CollisionShape2D.set_scale(Vector2(1, 0.5))
	$CollisionShape2D.position.y += 10
	
func on_animation_end():
	$AnimatedSprite.play("burning")
	
func _ready():
	$AnimatedSprite.connect("animation_finished", self, "on_animation_end")
