extends Effect

func tick(actor): 
    actor.use_mana(self, power)
    .tick(actor)