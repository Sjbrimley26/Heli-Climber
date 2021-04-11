extends MarginContainer

var max_health = 200.0
var multiplier = max_health / 100

var currently_equipped = 1

var last_check := 0.0

var tween

func adjust_health(hp):
	$VBoxContainer/HBoxContainer/HBoxContainer/CenterContainer/TextureProgress.value = hp / multiplier

func _process(delta):
	last_check += delta
	if last_check < 0.2:
		return

	last_check = 0.0
	var equipped = get_parent().get_parent().equipped
	for type in Global.ammo:
		var path = "VBoxContainer/Weapons/icon"
		if type == currently_equipped:
			path = "VBoxContainer/Weapons/Selected/icon"
		var icon = get_node(path + String(type))
		if Global.ammo[type] > 0:
			icon.visible = true
		else:
			icon.visible = false
	
	
	if equipped != currently_equipped:
		var selector = $VBoxContainer/Weapons/Selected
		var prev_equipped = selector.get_child(1)
		$VBoxContainer/Weapons/Selected.remove_child(prev_equipped)
		$VBoxContainer/Weapons.add_child(prev_equipped)
		$VBoxContainer/Weapons.move_child(prev_equipped, currently_equipped)
		$VBoxContainer/Weapons.remove_child(selector)
		var to_equip = $VBoxContainer/Weapons.get_child(equipped)
		$VBoxContainer/Weapons.remove_child(to_equip)
		selector.add_child(to_equip)
		$VBoxContainer/Weapons.add_child(selector)
		$VBoxContainer/Weapons.move_child(selector, equipped)
		currently_equipped = equipped
		if tween:
			$VBoxContainer/Weapons.modulate = Color(1, 1, 1, 1)
			_delete_tween(tween)
		tween = Tween.new()
		tween.interpolate_property($VBoxContainer/Weapons, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.3), 2.0)
		tween.connect("tween_all_completed", self, "_delete_tween", [tween])
		add_child(tween)
		tween.start()
		

func _delete_tween(t: Tween):
	t.queue_free()
	tween = null
