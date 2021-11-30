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
onready var mana_pool = $GUI/HBoxContainer/VBoxContainer/Mana/Background
onready var actor_info = $GUI/Actor_info_container
onready var camera = $Camera2D
onready var char_points = $GUI/HBoxContainer/VBoxContainer/HBoxContainer

var gem_full = preload("res://Assets/gem_full.png")
var gem_empty = preload("res://Assets/gem_empty.png")

export(int) var max_mana := 100
export(Resource) var next_scene
var mana : int

var hovered = null
var current_turn := 0
var selected = null
var selected_action = null
var target = null
var targeting := false
var active : Array

var animating := false

func _ready():
	rng.randomize()
	randomize()
	set_mana(max_mana)

	mana_pool.get_node("Button").connect("pressed", self, "_on_End_turn")

	action_list.connect("action_chosen", self, "_on_Action_chosen")
	for actor in party_actors:
		actor.connect("try_toggle", self, "_on_Actor_try_toggle")
		actor.connect("left_click", self, "_on_Actor_left_click")
		actor.connect("lost_mana", self, "_on_Actor_lost_mana")
		actor.connect("hovered", self, "_on_Actor_hovered")
	for actor in enemy_actors:
		actor.connect("left_click", self, "_on_Actor_left_click")
		actor.connect("lost_mana", self, "_on_Actor_lost_mana")
		actor.connect("hovered", self, "_on_Actor_hovered")
		actor.connect("die", self, "_on_Actor_die")

	$AnimationPlayer.play("Start")

func _on_End_turn():
	if !$AnimationPlayer.is_playing():
		end_turn()

func _on_Actor_die(actor):
	enemy_actors.erase(actor)
	if enemy_actors.size() == 0:
		$AnimationPlayer.play("Victory")

# Holy shit this is a mess
func animate_combat(attacker : Actor, victim : Actor):
	# attacker.untap()
	# victim.untap()
	$AnimationPlayer.play("Combat")

	animating = true
	for actor in party_actors:
		actor.get_node("Sprite").material.set_shader_param("active", false)
		actor.animating = true
		if actor != attacker and actor != victim:
			actor.get_node("AnimationPlayer").play("Move_back")
	for actor in enemy_actors:
		actor.get_node("Sprite").material.set_shader_param("active", false)
		actor.animating = true
		if actor != attacker and actor != victim:
			actor.get_node("AnimationPlayer").play("Move_eback")

	# actor_info.get_node("Party_actor_info").rect_position -= Vector2(300, 0)
	# actor_info.get_node("Enemy_actor_info").rect_position += Vector2(300, 0)

	if victim.team == Actor.Team.PARTY:
		victim.get_node("AnimationPlayer").play("Move_forward")
	else:
		victim.get_node("AnimationPlayer").play("Move_eforward")
	camera.get_node("Tween").interpolate_property(camera, "offset", null, Vector2(0, 30), 0.1)
	camera.get_node("Tween").start()
	camera.get_node("Tween").interpolate_property(camera, "zoom", null, Vector2(0.95, 0.95), 0.1)
	camera.get_node("Tween").start()

	yield(get_tree().create_timer(1), "timeout")

	camera.get_node("Tween").interpolate_property(camera, "zoom", null, Vector2(1, 1), 0.1)
	camera.get_node("Tween").start()
	camera.get_node("Tween").interpolate_property(camera, "offset", null, Vector2(0, 0), 0.1)
	camera.get_node("Tween").start()
	if victim.team == Actor.Team.PARTY:
		victim.get_node("AnimationPlayer").play("Move_freturn")
	else:
		victim.get_node("AnimationPlayer").play("Move_efreturn")

	# actor_info.get_node("Party_actor_info").rect_position += Vector2(300, 0)
	# actor_info.get_node("Enemy_actor_info").rect_position -= Vector2(300, 0)

	for actor in party_actors:
		actor.animating = false
		if actor != attacker and actor != victim:
			actor.get_node("AnimationPlayer").play("Move_breturn")
	for actor in enemy_actors:
		actor.animating = false
		if actor != attacker and actor != victim:
			actor.get_node("AnimationPlayer").play("Move_ebreturn")
	animating = false

func end_turn():
	mana_pool.get_node("ButtonH").hide()
	var active_actors = []
	for actor in party_actors:
		if actor.active:
			active_actors.append(actor)
	if active_actors.size() < 2:
		$AnimationPlayer.play("No_gems")
		print("No active actors")
		return

	current_turn = wrapi(current_turn + 1, 0, 2)

	if current_turn == Actor.Team.PARTY and mana == 0:
		print("end")
		$AnimationPlayer.play("Defeat")

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
			# for effect in actor.effects:
			# 	print(effect.name)
			# 	if effect.name == "Enflame":
			# 		effect.applied_by.get_node("AnimationPlayer").play("Move_forward")
			# 		animate_combat(effect.applied_by, actor)
			# 		yield(get_tree().create_timer(1.2), "timeout")
			# 		effect.applied_by.get_node("AnimationPlayer").play("Move_freturn")
			# 		yield(get_tree().create_timer(0.2), "timeout")



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
	if mana < 0:
		mana = 0
	mana_pool.get_node("Amount").value = mana
	$Tween.interpolate_property(mana_pool.get_node("Follow"), "value", null, mana, 0.4)
	$Tween.start()
	if current_turn == Actor.Team.PARTY and mana == 0:
		$AnimationPlayer.play("Defeat")

func set_mana(amount : int):
	mana = amount
	mana_pool.get_node("Amount").value = mana

func _unhandled_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			reset_selections()

	if event.is_action_pressed("end_turn") and !$AnimationPlayer.is_playing():
		end_turn()

func _on_Actor_try_toggle(actor : Actor, activate : bool):
	if targeting:
		reset_selections()
		return

	reset_selections()

	if animating:
		return

	if current_turn != 0:
		print("Enemy's turn")
		return 

	if actor.tapped:
		print("Actor's tapped")
		return

	if active.size() >= 2 and activate:
		$AnimationPlayer.play("No_gems")
		print("2 actors already active")
		return

	if activate:
		actor.activate()
		yield(actor, "animation_finished")
		active.append(actor)
		if active.size() == 2:
			char_points.get_node("1").get_node("Icon").texture = gem_empty
		elif active.size() == 1:
			char_points.get_node("2").get_node("Icon").texture = gem_empty
	else:
		actor.deactivate()
		yield(actor, "animation_finished")
		active.erase(actor)
		if active.size() == 1:
			char_points.get_node("1").get_node("Icon").texture = gem_full
		elif active.size() == 0:
			char_points.get_node("2").get_node("Icon").texture = gem_full

func _on_Actor_hovered(actor: Actor, p_hovered : bool):
	if animating:
		return

	if p_hovered:
		if actor.team == Actor.Team.PARTY:
			actor_info.get_node("Party_actor_info").display_actor_info(actor)
		if actor.team == Actor.Team.ENEMY:
			actor_info.get_node("Enemy_actor_info").display_actor_info(actor)

func _on_Actor_left_click(actor: Actor):
	if animating:
		return

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
				actor_use_action(selected, selected_action, target)
			else:
				set_target(null)

func _on_Actor_lost_mana(actor : Actor, amount : int):
	lose_mana(amount)

func actor_can_target(actor, action_index, p_target):
	return actor.actions[action_index].can_target.has(p_target.team)

func _on_Action_chosen(index : int):
	set_selected_action(index)
	if selected.actions[index].can_target.size() == 0:
		actor_use_action(selected, selected_action, selected)
	if target != null:
		if actor_can_target(selected, selected_action, target):
			actor_use_action(selected, selected_action, target)
		else:
			set_target(null)

func actor_use_action(actor : Actor, action_index : int, p_target : Actor):
	animate_combat(actor, p_target)
	# yield(get_tree().create_timer(0.05), "timeout")
	actor.use_action(action_index, p_target)
	$Action_used.text = (actor.name + " used " + actor.actions[action_index].name)
	reset_selections()
	if actor.team == Actor.Team.PARTY:
		check_full_turn()

func check_full_turn():
	var tapped = 0
	for actor in party_actors:
		if actor.tapped:
			tapped += 1

	if tapped == 2:
		mana_pool.get_node("ButtonH").show()
	else:
		mana_pool.get_node("ButtonH").hide()


func reset_selections():
	set_target(null)
	set_selected(null)
	set_selected_action(null)
	targeting = false
	action_list.close()


func _on_Retry():
	get_tree().reload_current_scene()


func _on_Victory():
	if next_scene != null:
		get_tree().change_scene_to(next_scene)
