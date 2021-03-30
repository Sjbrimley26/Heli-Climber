extends MarginContainer

func _ready():
	var _err = $VBoxContainer/CenterContainer2/NewGameButton.connect("pressed", self, "_new_game")
	var _err2 = $VBoxContainer/CenterContainer3/QuitButton.connect("pressed", self, "_quit")
	$VBoxContainer/HBoxContainer2/FloorLabel.text = String(Global.floor_reached)
	var enemies_killed = 0
	for i in Global.enemies_killed.values():
		enemies_killed += i
	$VBoxContainer/HBoxContainer/EnemyLabel.text = String(enemies_killed)
	
func _new_game():
	var _err = get_tree().change_scene("res://levels/LevelManager.tscn")

func _quit():
	get_tree().quit()
