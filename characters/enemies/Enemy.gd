extends KinematicBody2D

class_name Enemy

export(float) var MAX_HEALTH
export(int) var MAX_SPEED
export(int) var ACCELERATION

var target
var rng = RandomNumberGenerator.new()
var velocity = Vector2()

enum {STATE_IDLE, STATE_CHASING, STATE_ATTACKING}

var current_state = STATE_IDLE

var affected_by_gravity = false
const GRAVITY = 30

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
	var d10 = rng.randf_range(0, 10)
	if d10 <= 2.0:
		var hpack = load("res://props/HealthPack.tscn").instance()
		hpack.global_position = global_position
		get_parent().get_parent().call_deferred("add_child", hpack)
	if d10 > 2.0 and d10 <= 5.0:
		var ammo = load("res://props/Ammo.tscn").instance()
		ammo.global_position = global_position
		get_parent().get_parent().call_deferred("add_child", ammo)
	

func enemy_detected(body):
	if body.has_meta("type") and body.get_meta("type") == "player":
		target = body
		

func on_collision(body):
	if body.has_meta("type") and body.get_meta("type") == "projectile":
		emit_signal("hp_changed", -body.damage)
		

func on_animation_end(_name):
	pass        
	
func _is_target_in_sight():
	var in_sight = false
	if target:
		var space_state = get_world_2d().direct_space_state
		var raycast = space_state.intersect_ray(global_position, target.global_position, [self])
		in_sight = raycast.has("collider") and raycast["collider"] == target
	return in_sight
	
func _physics_process(_delta):
	match current_state:
		STATE_IDLE:
			# currently just sits until a target approaches
			if target != null:
				current_state = STATE_CHASING
			if affected_by_gravity:
				velocity.y = velocity.y + GRAVITY # fall
				velocity = move_and_slide(velocity, Vector2.UP)
