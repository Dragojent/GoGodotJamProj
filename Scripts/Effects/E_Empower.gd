extends Effect

func apply(actor):
    actor.stats.power += 10

func end(actor):
    actor.stats.power -= 10