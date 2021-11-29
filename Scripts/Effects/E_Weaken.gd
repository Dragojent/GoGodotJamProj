extends Effect

func apply(actor):
	actor.stats.power -= 5

func end(actor):
	actor.stats.power += 5