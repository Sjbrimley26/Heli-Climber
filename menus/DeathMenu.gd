extends MarginContainer

func _ready():
	var _err = $VBoxContainer/CenterContainer2/NewGameButton.connect("pressed", self, "_new_game")
	var _err2 = $VBoxContainer/CenterContainer3/QuitButton.connect("pressed", self, "_quit")
	
func _new_game():
	get_tree().change_scene("res://levels/LevelManager.tscn")

func _quit():
	get_tree().quit()
