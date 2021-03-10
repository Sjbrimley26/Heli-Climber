extends KinematicBody2D

export(float) var MAX_HEALTH
export(int) var MAX_SPEED
export(int) var ACCELERATION

var target

signal hp_changed(x)


# required Nodes: HealthBar, Detection, Detonation
func _ready():
    set_meta("type", "enemy")
    var hp_err = $HealthBar.connect("dead", self, "die")
    if hp_err != OK:
        print("error connecting HealthBar")
    var det_err = $Detection.connect("body_entered", self, "enemy_detected")
    if det_err != OK:
        print("error connecting Detection (Area2D)")
    var explosion_err = $Detonation.connect("animation_finished", self, "queue_free")
    if explosion_err != OK:
        print("error connecting Detonation")
    if has_node("AnimationPlayer"):
        var anim_err = $AnimationPlayer.connect("animation_finished", self, "on_animation_end")
        if anim_err != OK:
            print("error connecting AnimationPlayer")


func die():
    $CollisionShape2D.set_deferred("disabled", true)
    $HealthBar.visible = false
    $Detonation.visible = true
    $Detonation.playing = true
    if has_node("AnimationPlayer"):
        $AnimationPlayer.stop()
    if has_node("body"):
        $body.visible = false
    if has_node("head"):
        $head.visible = false
    set_physics_process(false)
    

func enemy_detected(body):
    if body.has_meta("type") and body.get_meta("type") == "player":
        target = body
        

func on_collision(body):
	if body.has_meta("type") and body.get_meta("type") == "projectile":
        emit_signal("hp_changed", -body.damage)
        

func on_animation_end(_name):
    pass        