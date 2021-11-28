extends Node2D

enum Enemy_type {
    DAMAGE,
    SUPPORT,
    HEXER
}

onready var mana_bar = $Stats/Mana

export(int) var max_mana := 100
export(Enemy_type) var enemy_type
var mana : int

signal die()

func _ready():
    set_mana(max_mana)
    mana_bar.max_value = max_mana

func set_max_mana(value : int):
    max_mana = value
    mana_bar.max_value = max_mana

func set_mana(value : int):
    mana = value
    mana_bar.value = mana

func lose_mana(amount : int):
    mana -= amount
    mana_bar.value = mana
    if mana <= 0:
        die()

func die():
    emit_signal("die")