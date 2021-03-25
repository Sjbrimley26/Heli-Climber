extends Node2D

class_name Level

signal trigger_next_level(height)
signal trigger_current_level(level)
signal enemy_change_level(enemy)
var enemies_sent = []

export var height = 800 # 25 blocks x 32px --- should be set in inherited levels

func _ready():
	var _err = $NextLevelTrigger.connect("body_entered", self, "next_level", [], CONNECT_ONESHOT)
	var _err2 = $CurrentLevelTrigger.connect("body_entered", self, "current_level", [], CONNECT_ONESHOT)
	var _err3 = $EnemyChaseTrigger.connect("body_entered", self, "enemy_change_level")
	
func next_level(_body):
	emit_signal("trigger_next_level", height)
	
func current_level(_body):
	emit_signal("trigger_current_level", self)
	
func enemy_change_level(body):
	if body in enemies_sent:
		return
	enemies_sent.append(body)
	emit_signal("enemy_change_level", body)
