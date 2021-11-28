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

func end(_actor):
	pass

# Triggered at the beginning of each turn
func tick(actor): 
	duration -= 1
	print(name + str(duration))
	if duration == 0:
		end(actor)
		emit_signal("expired", self)
