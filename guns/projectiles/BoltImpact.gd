extends Node2D


func _ready():
	var _err = get_tree().create_timer(0.2).connect("timeout", $Light2D, "queue_free")
