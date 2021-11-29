extends Effect

func apply(actor):
    actor.stats.armor -= 5

func end(actor):
    actor.stats.armor += 5