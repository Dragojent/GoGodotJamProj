extends Node2D

enum Enemy_type {
    DAMAGE,
    SUPPORT,
    HEXER
}

onready var mana_bar = $Stats/Mana

export(int) var max_mana := 50
export(Enemy_type) var enemy_type
var mana : int
var last_action := -1

signal die()

func _ready():
    set_mana(max_mana)
    mana_bar.max_value = max_mana

func set_max_mana(value : int):
    max_mana = value
    mana_bar.max_value = max_mana

func set_mana(value : int):
    mana = value
    $Stats/Follow.value = value
    mana_bar.value = mana

func lose_mana(amount : int):
    mana -= amount
    mana_bar.value = mana
    $Tween.interpolate_property($Stats/Follow, "value", null, mana, 0.8)
    $Tween.start()
    if mana <= 0:
        die()

func die():
    emit_signal("die")