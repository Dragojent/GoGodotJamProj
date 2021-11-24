extends Node2D

enum {
	MISS,
	HIT,
	CRIT
}

var rng = RandomNumberGenerator.new()

onready var party_actors := $Actors/Party.get_children()
onready var enemy_actors := $Actors/Enemies.get_children()
onready var enemy_ai = $Actors/Enemy_AI
onready var action_list = $GUI/Action_list_container/Action_list
onready var mana_pool = $GUI/HBoxContainer/VBoxContainer/Mana/Background/Amount

export(int) var max_mana := 100
var mana : int

var current_turn := 0
var selected = null
var selected_action = null
var target = null
var targeting := false
var active : Array


func _ready():
	randomize()
	set_mana(max_mana)

	action_list.connect("action_chosen", self, "_on_Action_chosen")
	for actor in party_actors:
		actor.connect("try_toggle", self, "_on_Actor_try_toggle")
		actor.connect("left_click", self, "_on_Actor_left_click")
		actor.connect("lost_mana", self, "_on_Actor_lost_mana")
	for actor in enemy_actors:
		actor.connect("left_click", self, "_on_Actor_left_click")
		actor.connect("lost_mana", self, "_on_Actor_lost_mana")

func end_turn():
	current_turn = wrapi(current_turn + 1, 0, 2)

	reset_selections()

	if current_turn == Actor.Team.PARTY:
		for actor in party_actors:
			actor.start_turn()
		for actor in enemy_actors:
			actor.end_turn()
	elif current_turn == Actor.Team.ENEMY:
		for actor in party_actors:
			actor.end_turn()
		for actor in enemy_actors:
			actor.start_turn()

		var active_actors = []
		for actor in party_actors:
			if actor.active:
				active_actors.append(actor)
		if active_actors.empty():
			print("No active actors")
		else:
			enemy_ai.start_turn(active_actors, enemy_actors)

func set_target(actor : Actor):
	if target != null:
		target.set_highlight(false)

	target = actor

	if target != null:
		target.set_highlight(true)

func set_selected(actor : Actor):
	if selected != null:
		selected.set_highlight(false)
	
	selected = actor

	if selected != null:
		selected.set_highlight(true)
	
func set_selected_action(action_index):
	if action_index == null:
		if selected_action != null:
			action_list.set_selected_action(selected_action, false)
		selected_action = null
	else:
		if selected_action != null:
			action_list.set_selected_action(selected_action, false)
		selected_action = action_index
		action_list.set_selected_action(selected_action, true)

func lose_mana(amount : int):
	mana -= amount
	if mana > 0:
		mana_pool.value = mana

func set_mana(amount : int):
	mana = amount
	mana_pool.value = mana

func _unhandled_input(event : InputEvent):
	if event.is_action_pressed("end_turn"):
		end_turn()

func _on_Actor_try_toggle(actor : Actor, activate : bool):
	if current_turn != 0:
		print("Enemy's turn")
		return 

	if actor.tapped:
		print("Actor's tapped")
		return

	if active.size() >= 2 and activate:
		print("2 actors already active")
		return

	if targeting:
		reset_selections()
		return

	if activate:
		actor.activate()
		active.append(actor)
	else:
		actor.deactivate()
		active.erase(actor)

func _on_Actor_left_click(actor: Actor):
	if !actor.tapped and actor.active and !targeting:
		set_selected(actor)
		action_list.display_actions(actor)
		targeting = true

	elif targeting:
		set_target(actor)
		if selected_action == null:
			pass
		elif selected_action != null:
			if actor_can_target(selected, selected_action, target):
				selected_use_action()
			else:
				set_target(null)

func _on_Actor_lost_mana(actor : Actor, amount : int):
	lose_mana(amount)

func actor_can_target(actor, action_index, p_target):
	return actor.actions[action_index].can_target.has(p_target.team)

func _on_Action_chosen(index : int):
	set_selected_action(index)
	if target != null:
		if actor_can_target(selected, selected_action, target):
			selected_use_action()
		else:
			set_target(null)

# func _roll() -> int:
#     return rng.randi_range(1, 100)

# func attack_roll(attacker : Actor, action_index : int, target : Actor):
# 	var hit_score = (attacker.stats.accuracy + attacker.actions[action_index].accuracy_bonus 
# 					- (target.stats.evasion + _roll()))

# 	if hit_score <= 0:
# 		return MISS
# 	if hit_score > 0 and hit_score <= 100:
# 		return HIT
# 	if hit_score > 100:
# 		return CRIT

func selected_use_action():
	selected.use_action(selected_action, target)
	reset_selections()

func reset_selections():
	set_target(null)
	set_selected(null)
	set_selected_action(null)
	targeting = false
	action_list.close()
