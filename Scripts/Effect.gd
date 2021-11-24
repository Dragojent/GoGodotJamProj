extends Resource
class_name Effect

export(String) var name := "N/A"

# -1            - infinite
# 0             - instant (damage, heal)
# 1 and above   - regular
export(int) var duration := 0
var power := 1.0
var applied_by = null

signal expired(effect)

# Triggered once when the effect is applied
func apply(_actor):
	pass

# Triggered at the beginning of each turn
func tick(_actor): 
	pass
	duration -= 1
	if duration == 0:
		emit_signal("expired", self)
