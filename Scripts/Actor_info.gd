extends MarginContainer

func display_actor_info(actor : Actor):
	$Rows/HBoxContainer/Name/NinePatchRect/Label.text = actor.name
	$Rows/PA/Power/NinePatchRect/Value.text = str(actor.stats.power)
	$Rows/PA/Armor/NinePatchRect/Value.text = str(actor.stats.armor)
	$Rows/AE/Accuracy/NinePatchRect/Value.text = str(actor.stats.accuracy)
	$Rows/AE/Evasion/NinePatchRect/Value.text = str(actor.stats.evasion)
	show()
