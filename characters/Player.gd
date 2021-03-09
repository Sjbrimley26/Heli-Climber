extends KinematicBody2D

signal fire(direction)

# signal hp_changed(amount)

var velocity = Vector2(0,0)
const SPEED = 250
const GRAVITY = 30
const JUMP = -900

enum {PISTOL, RIFLE, LAUNCHER, BOLT_LAUNCHER, BAT, SWORD}
var fireRates = [
	3,
	0.8,
	8,
	8,
	6,
	3
]
var prevEquipped
var equipped = SWORD
var reloading = 0

var pistol = preload("res://guns/Pistol.tscn")
var rifle = preload("res://guns/Rifle.tscn")
var launcher = preload("res://guns/Launcher.tscn")
var bolt_launcher = preload("res://guns/BoltLauncher.tscn")
var bat = preload("res://guns/Bat.tscn")
var sword = preload("res://guns/Sword.tscn")

func _ready():
	set_meta("type", "player")

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
		if equipped == SWORD:
			equipped = PISTOL
		else:
			equipped = equipped + 1
	
	if Input.is_action_just_pressed("weapon_prev"):
		if equipped == PISTOL:
			equipped = SWORD
		else:
			equipped = equipped - 1
	
	# Check Weapon
	var gun
	match equipped:
		PISTOL:
			gun = pistol
		RIFLE:
			gun = rifle
		LAUNCHER:
			gun = launcher
		BOLT_LAUNCHER:
			gun = bolt_launcher
		BAT:
			gun = bat
		SWORD:
			gun = sword
			
	if not equipped == prevEquipped:
		var newlyEquipped = gun.instance()
		if prevEquipped != null:
			get_node("Gun").free()
		prevEquipped = equipped
		add_child(newlyEquipped)
	
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
		

