extends KinematicBody2D

class_name Enemy

export(float) var MAX_HEALTH
export(int) var MAX_SPEED
export(int) var ACCELERATION

var target
var rng = RandomNumberGenerator.new()

signal hp_changed(x)

# required Nodes: HealthBar, Detection, Detonation
func _ready():
	rng.randomize()
	set_meta("type", "enemy")
	var hp_err = $HealthBar.connect("dead", self, "die")
	if hp_err != OK:
		print("error connecting HealthBar")
	$HealthBar.set_max_health(MAX_HEALTH)
	var det_err = $Detection.connect("body_entered", self, "enemy_detected")
	if det_err != OK:
		print("error connecting Detection (Area2D)")
	var explosion_err = $Detonation.connect("animation_finished", self, "queue_free")
	if explosion_err != OK:
		print("error connecting Detonation")
	if has_node("AnimationPlayer"):
		var anim_err = $AnimationPlayer.connect("animation_finished", self, "on_animation_end")
		if anim_err != OK:
			print("error connecting AnimationPlayer")


func die():
	$CollisionShape2D.set_deferred("disabled", true)
	$HealthBar.visible = false
	$Detonation.visible = true
	$Detonation.playing = true
	if has_node("AnimationPlayer"):
		$AnimationPlayer.stop()
	if has_node("body"):
		$body.visible = false
	if has_node("head"):
		$head.visible = false
	set_physics_process(false)
	var type = get_meta("enemy")
	Global.enemies_killed[type] += 1
	if rng.randf_range(0, 10) <= 2.5:
		var hpack = load("res://props/HealthPack.tscn").instance()
		hpack.global_position = global_position
		get_parent().call_deferred("add_child", hpack)
		
	

func enemy_detected(body):
	if body.has_meta("type") and body.get_meta("type") == "player":
		target = body
		

func on_collision(body):
	if body.has_meta("type") and body.get_meta("type") == "projectile":
		emit_signal("hp_changed", -body.damage)
		

func on_animation_end(_name):
	pass        
