extends Resource
class_name Action

var rng = RandomNumberGenerator.new()

export(String) var name = "N/A"
export(String) var overview = "N/A"
export(Array, Actor.Team) var can_target = [Actor.Team.PARTY, Actor.Team.ENEMY]

export(int) var mana_cost := 0

export(float) var power := 1.0
export(int) var accuracy_bonus = 0
export(Array, Resource) var effects := []
export(Array, Resource) var self_effects := []

func execute(actor, target, power_multiplier := 1.0):
	if mana_cost > 0:
		actor.use_mana(self, mana_cost)

	power_multiplier = power_multiplier * rng.randf_range(0.8, 1.2)

	if power_multiplier == 0:
		return

	for effect in effects:
		var new_effect = effect.duplicate()
		new_effect.applied_by = actor
		new_effect.power = actor.stats.power * power * power_multiplier
		target.receive_effect(new_effect)
	for effect in self_effects:
		var new_effect = effect.duplicate()
		new_effect.applied_by = actor
		new_effect.power = actor.stats.power * power * power_multiplier
		actor.receive_effect(new_effect)
