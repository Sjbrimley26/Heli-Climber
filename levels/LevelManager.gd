extends Node2D

const MAX_HEIGHT = 1000000

const LEVELS = [
	#"res://levels/Level2.tscn",
	#"res://levels/Level3.tscn",
	#"res://levels/Level4.tscn",
	"res://levels/Level5.tscn"
]

const CAN_USE_THREADS = false

var thread
var mutex
var rng = RandomNumberGenerator.new()

var prev_level: Level
var current_level: Level
var current_height = 0
var height_reached = 0 # updated when a new room is entered, need a way to factor in the "final height" when the player dies
var floor_reached = 0

func _ready():
	rng.randomize()
	_change_current_level($Level1)
	var timer = Timer.new()
	timer.set_wait_time(0.25)
	var _err = timer.connect("timeout", Global, "update_floor_color")
	add_child(timer)
	timer.start()
	if CAN_USE_THREADS:
		thread = Thread.new()
		mutex = Mutex.new()
	
func _spawn_thread(h):
	thread.start(self, "_spawn_new_level", h)
	
func _spawn_new_level(height):
	# so it will just select a level randomly from the list for now
	# eventually I could implement a set of easy, medium, and hard levels that would be selected based on height_reached
	# maybe a boss room appears after a certain height? or even a certain # of floors reached?
	
	var new_level = load(LEVELS[rng.randi_range(0, LEVELS.size() - 1)]).instance()
	new_level.set_deferred("position", Vector2(0, new_level.position.y - (height + current_height)))
	mutex.lock()
	current_height += height
	mutex.unlock()
	var _err = new_level.connect("trigger_current_level", self, "_change_current_level", [], CONNECT_ONESHOT)
	#call_deferred("add_child", new_level) - this causes a bunch of errors
	var _err2 = get_tree().create_timer(0.2).connect("timeout", self, "add_child", [new_level]) # this works though
	# big thank you to Yogoda (on Github)
	# 0.0 usually works but sometimes causes errors, 0.2 is safer
	thread.call_deferred("wait_to_finish")
	
func _spawn_new_level_threadless(height):
	var new_level = load(LEVELS[rng.randi_range(0, LEVELS.size() - 1)]).instance()
	new_level.set_deferred("position", Vector2(0, new_level.position.y - (height + current_height)))
	current_height += height
	var _err = new_level.connect("trigger_current_level", self, "_change_current_level", [], CONNECT_ONESHOT)
	#call_deferred("add_child", new_level) - this causes a bunch of errors
	var _err2 = get_tree().create_timer(0.2).connect("timeout", self, "add_child", [new_level])
	
	
func _change_current_level(level: Level):
	floor_reached += 1
	Global.floor_reached = floor_reached
	if prev_level:
		prev_level.queue_free()
		# so delete any level that is 2 "chunks" below the chatacter
		# TODO: shifting everything downward causes a weird camera jitter
		# so it'll basically be disabled unless I run into issues, in which case I'll adjust the MAX_HEIGHT
		if current_height >= MAX_HEIGHT:
			var shift = $Player.position.y
			for n in get_children():
				n.position.y -= shift
			height_reached += current_height
			current_height = 0
	if current_level:
		prev_level = current_level
		var _err2 = prev_level.get_node("CurrentLevelTrigger").connect("body_entered", self, "_kill_player", [], CONNECT_ONESHOT)
		prev_level.disconnect("enemy_change_level", self, "_enemy_change_level")
		var _err4 = prev_level.connect("enemy_change_level", self, "_kill_enemy")
		prev_level.enemies_sent = []
		# if they fall further than that, they should die (there will be nothing below)
	current_level = level
	var new_level_func
	if CAN_USE_THREADS:
		new_level_func = "_spawn_thread"
	else:
		new_level_func = "_spawn_new_level_threadless"
		
	var _err = current_level.connect("trigger_next_level", self, new_level_func, [], CONNECT_ONESHOT)
	# as they enter a new area, it becomes the current room and the one they just left becomes the previous room
	var _err3 = current_level.connect("enemy_change_level", self, "_enemy_change_level")
	# the camera is restricted so it doesn't go left or right over the current level
	var tilemap = current_level.get_node("Floors")
	var map_limits = tilemap.get_used_rect()
	var map_cell_size = tilemap.cell_size
	$Player/Camera2D.limit_left = map_limits.position.x * map_cell_size.x
	$Player/Camera2D.limit_right = map_limits.end.x * map_cell_size.x

func _kill_player(_player):
	Global.death_reason = "fall"
	var _err = get_tree().change_scene("res://menus/DeathMenu.tscn")
	
func _kill_enemy(enemy: Enemy):
	enemy.queue_free()
	
func _enemy_change_level(enemy: Enemy):
	call_deferred("_change_level", enemy)

func _change_level(enemy):
	var pos = enemy.global_position
	enemy.get_parent().remove_child(enemy)
	current_level.add_child(enemy)
	enemy.global_position = pos 
	# seems to be working for the most part
	# if enemies cross into the next level before the player they get deleted with the previous chunk though
	
