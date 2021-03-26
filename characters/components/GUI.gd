extends MarginContainer

var max_health = 200.0
var multiplier = max_health / 100

func adjust_health(hp):
	$HBoxContainer/HBoxContainer/CenterContainer/TextureProgress.value = hp / multiplier
