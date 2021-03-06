extends KinematicBody2D

class_name Player

signal fire(direction)
signal ohm(direction)

signal hp_changed(hp)

var velocity = Vector2(0,0)
const SPEED = 250
const GRAVITY = 30
const JUMP = -900
const MAX_HEALTH = 200.0

var health = 200.0

enum {SWORD, PISTOL, RIFLE, LAUNCHER, BOLT_LAUNCHER, BAT, SAW}
var gun_names = {
	SWORD: "SWORD",
	PISTOL: "PISTOL",
	RIFLE: "RIFLE",
	LAUNCHER: "ROCKET",
	BOLT_LAUNCHER: "BOLT GUN",
	BAT: "BAT",
	SAW: "SAW"
}
var fireRates = [
	3,
	3,
	0.8,
	8,
	8,
	4.5,
	0.5
]
var prevEquipped
var equipped = PISTOL
var reloading = 0
var camera_shaking = false
var recent_damage = 1

var pistol = preload("res://guns/Pistol.tscn")
var rifle = preload("res://guns/Rifle.tscn")
var launcher = preload("res://guns/Launcher.tscn")
var bolt_launcher = preload("res://guns/BoltLauncher.tscn")
var bat = preload("res://guns/Bat.tscn")
var sword = preload("res://guns/Sword.tscn")
var saw = preload("res://guns/SawLauncher.tscn")

var pistol_icon = preload("res://img/ui/pistol.png")
var rifle_icon = preload("res://img/ui/rifle.png")
var launcher_icon = preload("res://img/ui/rocket.png")
var bolt_icon = preload("res://img/ui/bolt.png")
var bat_icon = preload("res://img/ui/bat.png")
var sword_icon = preload("res://img/ui/sword.png")
var saw_icon = preload("res://img/ui/saw.png")

var hit_sound = preload("res://sounds/damage.wav")

var death_menu = preload("res://menus/DeathMenu.tscn")

func on_collision(area):
	recent_damage += area.damage / 10.0
	camera_shaking = true
	var timer = Timer.new()
	timer.set_wait_time(1)
	var _err = timer.connect("timeout", self, "stop_camera_shake", [timer])
	add_child(timer)
	timer.start()
	var splayer = AudioStreamPlayer.new()
	splayer.stream = hit_sound
	var _err2 = splayer.connect("finished", splayer, "queue_free")
	add_child(splayer)
	splayer.play()
	health -= area.damage
	emit_signal("hp_changed", health)
	if health <= 0:
		if area.has_meta("origin"):
			Global.death_reason = area.get_meta("origin")
		var _err3 = get_tree().change_scene_to(death_menu)
	
func stop_camera_shake(timer):
	recent_damage = 1
	timer.queue_free()
	camera_shaking = false
	$Camera2D.set_offset(Vector2.ZERO)

func _ready():
	set_meta("type", "player")
	var _err = connect("hp_changed", $CanvasLayer/GUI, "adjust_health")

func _next_weapon():
	var toEquip
	for i in range(1, fireRates.size()):
		var index: int
		if equipped + i < fireRates.size():
			index = equipped + i
		else:
			index = (equipped + i) % fireRates.size()
			
		if (Global.ammo[index] > 0):
			toEquip = index
			break
	equipped = toEquip

func _physics_process(_delta):
	# Update Movement
	if Input.is_action_pressed("right"):
		$Sprite.play("walk")
		velocity.x = SPEED
		
	if Input.is_action_pressed("left"):
		velocity.x = -SPEED
		$Sprite.play("walk")
		
	if not Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		$Sprite.play("idle")
		
	if Input.is_action_pressed("up") and is_on_floor():
		velocity.y = JUMP
		
	velocity.y = velocity.y + GRAVITY
	
	velocity = move_and_slide(velocity, Vector2.UP)

	velocity.x = lerp(velocity.x, 0, 0.1)
	
	# Swap Weapons
	if Input.is_action_just_pressed("weapon_next"):
		_next_weapon()
	
	if Input.is_action_just_pressed("weapon_prev"):
		var toEquip
		for i in range(-1, -fireRates.size(), -1):
			var index: int
			if equipped + i >= 0:
				index = equipped + i
			else:
				index = (equipped + i) + (fireRates.size())
				
			if (Global.ammo[index] > 0):
				toEquip = index
				break
		equipped = toEquip
		
	# Swap if out of ammo
	if Global.ammo[equipped] <= 0:
		_next_weapon()
	
	# Check Weapon
	var gun
	var icon
	match equipped:
		PISTOL:
			gun = pistol
			icon = pistol_icon
		RIFLE:
			gun = rifle
			icon = rifle_icon
		LAUNCHER:
			gun = launcher
			icon = launcher_icon
		BOLT_LAUNCHER:
			gun = bolt_launcher
			icon = bolt_icon
		BAT:
			gun = bat
			icon = bat_icon
		SWORD:
			gun = sword
			icon = sword_icon
		SAW:
			gun = saw
			icon = saw_icon
			
	if not equipped == prevEquipped:
		var newlyEquipped = gun.instance()
		if prevEquipped != null:
			get_node("Gun").free()
		prevEquipped = equipped
		add_child(newlyEquipped)
		$CanvasLayer/GUI.get_node("VBoxContainer/HBoxContainer/CenterContainer/GunIcon").texture = icon
	
	$CanvasLayer/GUI/VBoxContainer/HBoxContainer/CenterContainer2/AmmoCount.text = String(Global.ammo[equipped])
	$CanvasLayer/GUI/VBoxContainer/HBoxContainer/CenterContainer3/Equipped.text = gun_names[equipped]
	
	var localMouse = get_local_mouse_position()
	var globalMouse = get_global_mouse_position()
	if localMouse.x < 0:
		get_node("Gun").set_scale(Vector2(1, -1))
		$Sprite.flip_h = true
	else:
		get_node("Gun").set_scale(Vector2(1, 1))
		$Sprite.flip_h = false
	get_node("Gun").look_at(globalMouse)
	
	# Check to Fire
	reloading -= 0.1
	if Input.is_action_pressed("click") and reloading <= 0:
		var dir = globalMouse - global_position
		emit_signal("fire", dir)
		reloading = fireRates[equipped]
		
	# OHM = super blast
	if Input.is_action_pressed("r_click") and reloading <= 0 and $CanvasLayer/GUI.ohm == 100:
		var dir = globalMouse - global_position
		emit_signal("ohm", dir)
		reloading = fireRates[equipped]
		
	# Camera follow mouse
	var mouse_offset = (get_viewport().get_mouse_position() - get_viewport().size / 2)
	$Camera2D.position = lerp(Vector2(), mouse_offset.normalized() * 400, mouse_offset.length() / 800)
		
	# Camera Shake if recently damaged
	var shake_amount = 1.0 * recent_damage
	if camera_shaking:
		$Camera2D.set_offset(Vector2( \
		rand_range(-1.0, 1.0) * shake_amount, \
		rand_range(-1.0, 1.0) * shake_amount \
	))
	

