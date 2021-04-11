extends "res://guns/projectiles/Bullet.gd"

var explosion_sound = preload("res://sounds/explosion_1.wav")

signal trigger_aoe

func _ready():
	$AOE.set_origin("launcher")

func _init():
	speed = 400
	set_damage(10)

func _lights_out():
	$Light2D.visible = false

func on_collide():
	$Light2D.visible = true
	var flash_duration = 0.3
	var _err3 = get_tree().create_timer(flash_duration).connect("timeout", self, "_lights_out")
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($Light2D, "texture_scale", 0.15, 0.25, flash_duration)
	tween.start()
	var splayer = AudioStreamPlayer2D.new()
	splayer.stream = explosion_sound
	var _err2 = splayer.connect("finished", splayer, "queue_free")
	add_child(splayer)
	splayer.play()
	vel = Vector2()
	$CollisionShape2D.set_disabled(true)
	$AnimatedSprite.play("explode")
	var _err = $AnimatedSprite.connect("animation_finished", self, "queue_free")
	emit_signal("trigger_aoe")
	
