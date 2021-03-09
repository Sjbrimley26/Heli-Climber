extends StaticBody2D

signal hp_changed(amount)

func _ready():
	set_meta('type', 'enemy')
	$AnimatedSprite.connect("animation_finished", self, "queue_free")
	$HealthBar.connect("dead", $AnimatedSprite, "play")
	$HealthBar.set_max_health(10.0)
	
func on_collision(body):
	if body.get_meta("type") == "projectile":
		emit_signal("hp_changed", -body.damage)
		
