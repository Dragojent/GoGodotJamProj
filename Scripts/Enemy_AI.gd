extends Node

enum {
	DAMAGE,
	SUPPORT,
	HEXER
}

export(Curve) var evasion_curve

func start_turn(party_actors, enemy_actors):
	for actor in enemy_actors:
		# var target = choose_target(actor, party_actors, enemy_actors)
		# var action = choose_action(actor, target)


		# if action == null:
		# 	print("No action selected")
		# 	continue
		var action = wrapi(actor.get_node("Enemy_stats").last_action + 1, 0, actor.actions.size())
		actor.get_node("Enemy_stats").last_action = action
		var target = find_target(actor, action, enemy_actors, party_actors)


		# actor.use_action(action, target)
		get_parent().get_parent().actor_use_action(actor, action, target)
		yield(get_tree().create_timer(1.5), "timeout")
	get_parent().get_parent().end_turn()


func will_survive_action(actor, action_index):
	if actor.get_node("Enemy_stats").mana <= actor.actions[action_index].mana_cost:
		return false
	else:
		return true

func find_target(actor, action_index, enemy_actors, party_actors):
	var target = null
	var max_target_desirability = -100
	if actor.actions[action_index].can_target.has(Actor.Team.PARTY):
		for i_actor in enemy_actors:
			i_actor.attack_priority += 1
			var desirability = i_actor.attack_priority
			if desirability > max_target_desirability:
				target = i_actor
				max_target_desirability = desirability
		target.attack_priority -= 2
	else:
		for i_actor in party_actors:
			var desirability = i_actor.attack_priority
			if desirability > max_target_desirability:
				target = i_actor
				max_target_desirability = desirability
	return target



# func choose_target(actor, party_actors, enemy_actors):
# 	var max_target_desirability = -100
# 	var target = null
# 	match actor.get_node("Enemy_stats").enemy_type:
# 		DAMAGE:
# 			for i_actor in party_actors:
# 				var desirability = i_actor.attack_priority
# 				if desirability > max_target_desirability:
# 					target = i_actor
# 					max_target_desirability = desirability
# 		SUPPORT:
# 			for i_actor in enemy_actors:
# 				var i_stats = i_actor.stats
# 				var desirability = ((i_stats.power
# 									- i_stats.armor)
# 									/ evasion_curve.interpolate(i_stats.evasion / 100.0))
# 				if desirability > max_target_desirability:
# 					target = i_actor
# 					max_target_desirability = desirability
# 		HEXER:
# 			var target_desirability = 100
# 			for i_actor in party_actors:
# 				var desirability = i_actor.attack_priority
# 				if desirability < target_desirability:
# 					target = i_actor
# 					max_target_desirability = desirability
# 	return target

# func choose_action(actor, target):
# 	var max_action_desirability = -100000
# 	var action = null
# 	for action_index in actor.actions.size():
# 		var i_action = actor.actions[action_index]
# 		if !actor.can_target(action_index, target):
# 			continue

# 		var desirability : float
# 		if !will_survive_action(actor, action_index):
# 			desirability = -99999
# 		else:
# 			desirability = ((actor.get_node("Enemy_stats").mana
# 								- i_action.mana_cost)
# 								* i_action.power
# 								* i_action.effects.size()
# 								/ (i_action.self_effects.size() + 1))
# 		if desirability > max_action_desirability:
# 			action = action_index
# 	return action
