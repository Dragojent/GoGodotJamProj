extends Effect

func apply(actor):
    actor.stats.armor += int(power / 4)

func end(actor):
    actor.stats.armor -= int(power / 4)