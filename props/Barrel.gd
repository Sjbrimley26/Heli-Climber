extends StaticBody2D

signal trigger_aoe()
const MAX_HITS = 2
var hit_count = 0
var explosion_played = false

func on_collision(body):
	if body.has_meta("type") and body.get_meta("type") == "projectile":
		if hit_count == MAX_HITS:
			explode()
		hit_count += 1
		
func explode():
	$Light2D.visible = true
	var _err = get_tree().create_timer(0.4).connect("timeout", self, "_lights_out")
	$AnimatedSprite.play("explode")
	emit_signal("trigger_aoe")
	$CollisionShape2D.set_scale(Vector2(1, 0.5))
	$CollisionShape2D.position.y += 10
	
func on_animation_end():
	if explosion_played:
		return
	explosion_played = true
	$AnimatedSprite.play("burning")
	var timer = Timer.new()
	var _err = timer.connect("timeout", self, "fade_out", [], CONNECT_ONESHOT)
	timer.set_one_shot(true)
	timer.set_wait_time(4)
	add_child(timer)
	timer.start()
	
func fade_out():
	var tween = Tween.new()
	tween.interpolate_property($AnimatedSprite, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	var _err = tween.connect("tween_all_completed", self, "queue_free")
	add_child(tween)
	tween.start()
	
func _lights_out():
	$Light2D.visible = false
	
func _ready():
	var _err = $AnimatedSprite.connect("animation_finished", self, "on_animation_end")
	set_meta("type", "prop")
	$AOE.set_origin("barrel")
	
