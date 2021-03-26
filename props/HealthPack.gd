extends Area2D

export var heal_amount = 50.0

func _ready():
	var _err = connect("body_entered", self, "_heal")
	
func _heal(player: Player):
	player.health += heal_amount
	if player.health > player.MAX_HEALTH:
		player.health = player.MAX_HEALTH
	player.emit_signal("hp_changed", player.health)
	queue_free()
