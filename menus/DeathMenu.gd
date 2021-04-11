extends MarginContainer

func _ready():
	var _err = $VBoxContainer/CenterContainer2/NewGameButton.connect("pressed", self, "_new_game")
	var _err2 = $VBoxContainer/CenterContainer3/QuitButton.connect("pressed", self, "_quit")
	$VBoxContainer/HBoxContainer2/FloorLabel.text = String(Global.floor_reached)
	var enemies_killed = 0
	for i in Global.enemies_killed.values():
		enemies_killed += i
	$VBoxContainer/HBoxContainer/EnemyLabel.text = String(enemies_killed)
	var msg = "You Died!"
	if Global.death_reason != "":
		match Global.death_reason:
			"runner": 
				msg = "You Were Chomped by a Runner!"
			"drone":
				msg = "You got Blasted by a Heli Drone!"
			"hoverbot":
				msg = "You were Zapped by a Hover Bot!"
			"fall":
				msg = "You fell to your Demise!"
			"barrel":
				msg = "You were Blown Up by a Barrel!"
			"launcher":
				msg = "A Stray Rocket Exploded too Close!"
			"turret":
				msg = "You were Shot Up by a Turret!"
			
	$VBoxContainer/CenterContainer/DeathLabel.text = msg
	
func _new_game():
	for i in Global.ammo.keys():
		Global.ammo[i] = 0
	Global.ammo[Global.PISTOL] = 999
	Global.ammo[Global.SWORD] = 1
	for i in Global.enemies_killed.keys():
		Global.enemies_killed[i] = 0
	Global.death_reason = ""
	var _err = get_tree().change_scene("res://levels/LevelManager.tscn")

func _quit():
	get_tree().quit()
