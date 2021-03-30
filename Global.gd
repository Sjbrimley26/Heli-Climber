extends Node

enum {PISTOL, RIFLE, LAUNCHER, BOLT_LAUNCHER, BAT, SWORD, SAW}

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
	SWORD: 100,
	SAW: 0
}
