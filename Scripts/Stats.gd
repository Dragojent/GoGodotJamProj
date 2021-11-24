extends Resource
class_name Stats

export(int) var upkeep := 1 # drains this amount of mana ant the end of the turn if active

export(int) var evasion := 0 # Checked against accuracy for hit
export(int) var armor := 0 # Decreases damage received by a flat number

export(int) var power := 0 # Duh
export(int) var accuracy := 0 # Checked against enemy evasion for hit