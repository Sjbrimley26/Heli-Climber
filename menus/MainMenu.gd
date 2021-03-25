extends MarginContainer

var Game = preload("res://levels/LevelManager.tscn")

func _ready():
	var _err = $VBoxContainer/HBoxContainer/CenterContainer/VBoxContainer/NewGameButton.connect("pressed", self, "_start_new_game")
	
func _start_new_game():
	var _err = get_tree().change_scene_to(Game)
