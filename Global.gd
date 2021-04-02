extends Node

enum {PISTOL, RIFLE, LAUNCHER, BOLT_LAUNCHER, BAT, SWORD, SAW}

var floor_shader = preload("res://shaders/floor_shadermaterial.tres")

const COLORS = [
	Color(0.548, 1.0, 1.0, 1.0),
	Color(0.661, 0.887, 1.0, 1.0),
	Color(0.774, 0.774, 1.0, 1.0),
	Color(0.887, 0.661, 1.0, 1.0),
	Color(1.0, 0.548, 1.0, 1.0),
	Color(1.0, 0.661, 0.887, 1.0),
	Color(1.0, 0.774, 0.774, 1.0),
	Color(1.0, 0.887, 0.661, 1.0),
	Color(1.0, 1.0, 0.548, 1.0),
	Color(0.887, 1.0, 0.661, 1.0),
	Color(0.774, 1.0, 0.774, 1.0),
	Color(0.668, 1.0, 0.887, 1.0)
]

var color_index = 0

func update_floor_color():
	color_index += 1
	if color_index > COLORS.size() - 1:
		color_index = 0
	floor_shader.set_shader_param("glow", COLORS[color_index])

var floor_reached = 0

var enemies_killed = {
	"runner": 0,
	"drone": 0
}

var ammo = {
	PISTOL: 100,
	RIFLE: 0,
	LAUNCHER: 0,
	BOLT_LAUNCHER: 0,
	BAT: 0,
	SWORD: 1,
	SAW: 0
}
