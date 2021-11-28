extends Effect

func apply(actor):
	actor.attack_priority = 6

func end(actor):
	actor.attack_priority = 1