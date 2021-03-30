extends Node2D

const MAX_HEIGHT = 1000000

const LEVELS = [
	"res://levels/Level2.tscn"
]

var rng = RandomNumberGenerator.new()

var prev_level: Level
var current_level: Level
var current_height = 0
var height_reached = 0 # updated when a new room is entered, need a way to factor in the "final height" when the player dies
var floor_reached = 0

func _ready():
	rng.randomize()
	_change_current_level($Level1)
	
func _spawn_new_level(height):
	var next_level = load(LEVELS[rng.randi_range(0, LEVELS.size() - 1)]) # so it will just select a level randomly from the list for now
	# eventually I could implement a set of easy, medium, and hard levels that would be selected based on height_reached
	# maybe a boss room appears after a certain height? or even a certain # of floors reached?
	var new_level = next_level.instance()
	new_level.position.y -= height + current_height
	current_height += height
	var _err = new_level.connect("trigger_current_level", self, "_change_current_level", [], CONNECT_ONESHOT)
	call_deferred("add_child", new_level)
	
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
	var _err = current_level.connect("trigger_next_level", self, "_spawn_new_level", [], CONNECT_ONESHOT)
	# as they enter a new area, it becomes the current room and the one they just left becomes the previous room
	var _err3 = current_level.connect("enemy_change_level", self, "_enemy_change_level")

func _kill_player(_player):
	print("end scene")
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
	
