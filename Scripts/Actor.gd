extends Node2D
class_name Actor

var rng = RandomNumberGenerator.new()

enum {
	MISS,
	HIT,
	CRIT
}

enum Team{
	PARTY,
	ENEMY
}

onready var animation_player = $AnimationPlayer

export(Resource) var stats
export(Team) var team := Team.PARTY
export(Array, Resource) var actions := []
export(Array, Texture) var sprites := []

var tapped := false
var active := false

var effects := []

signal try_toggle(actor, active)
signal left_click(actor)
signal lost_mana(actor, amount)
signal hovered(actor, entered)
signal animation_finished()

func _ready():
	$Click_area.connect("mouse_entered", self, "_on_Click_area_mouse_entered")
	$Click_area.connect("mouse_exited", self, "_on_Click_area_mouse_exited")
	$Click_area.connect("gui_input", self, "_on_Click_area_input")

	set_sprite(1)
	animation_player.play("Untap")
	animation_player.connect("animation_finished", self, "_on_Animation_finished")

	$Sprite.rect_pivot_offset = $Sprite.rect_size / 2

func _on_Animation_finished(anim_name):
	emit_signal("animation_finished")

func _on_Click_area_mouse_entered():
	$Sprite.material.set_shader_param("active", true)
	emit_signal("hovered", self, true)

func _on_Click_area_mouse_exited():
	$Sprite.material.set_shader_param("active", false)
	emit_signal("hovered", self, false)

func set_sprite(sprite_index : int):
	if sprites[sprite_index] != null:
		$Sprite.texture = sprites[sprite_index]

# areas shouldn't overlap
func _on_Click_area_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if team == Team.PARTY:
				if active:
					emit_signal("try_toggle", self, false)
				else:
					emit_signal("try_toggle", self, true)

		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("left_click", self)

	else:
		pass

func set_highlight(state : bool):
	if state == true:
		$Sprite.modulate = Color(1, 0, 0, 1)
	else:
		$Sprite.modulate = Color(1, 1, 1, 1)

# func _input(event):
# 	if event is InputEventMouseButton:
# 		if event.button_index == BUTTON_LEFT and event.pressed:
# 			# ! Remember this moment and hate life

# 			activate()
# 			emit_signal("activated", self)

func tap():
	animation_player.queue("Tap")
	tapped = true

func untap():
	animation_player.queue("Untap")
	tapped = false

func start_turn():
	for effect in effects:
		effect.tick(self)
	untap()

func end_turn():
	if team == Team.ENEMY:
		untap()

	if active and team == Team.PARTY:
		use_mana(self, stats.upkeep)

func receive_effect(effect : Effect):
	effect.connect("expired", self, "_on_Effect_expired")
	effect.apply(self)
	if effect.duration != 0:
		effects.append(effect)

func use_mana(source, amount : int):
	if source is Effect:
		amount -= stats.armor
	if amount <= 0:
		return

	if team == Team.PARTY:
		emit_signal("lost_mana", self, amount)
	elif team == Team.ENEMY:
		get_node("Enemy_stats").lose_mana(amount)

func use_action(action_index : int, target):
	animation_player.play("Use_action")

	var power_multiplier = 0.0
	match attack_roll(action_index, target):
		MISS:
			power_multiplier = 0
		HIT:
			power_multiplier = 1
		CRIT:
			power_multiplier = 1.5

	print(str(self) + " used " + actions[action_index].name + " on " + str(target) + ": ")
	actions[action_index].execute(self, target, power_multiplier)
	tap()

func _roll() -> int:
	return rng.randi_range(1, 100)

func attack_roll(action_index : int, target : Actor):
	var hit_score = (stats.accuracy + actions[action_index].accuracy_bonus 
					- (target.stats.evasion + _roll()))

	if hit_score <= 0:
		return MISS
	if hit_score > 0 and hit_score <= 100:
		return HIT
	if hit_score > 100:
		return CRIT

func can_target(action_index : int, target : Actor) -> bool:
	if actions[action_index].can_target.has(Team.PARTY):
		if team == target.team:
			return true
		else:
			return false
	if actions[action_index].can_target.has(Team.ENEMY):
		if team != target.team:
			return true
		else:
			return false
	else:
		return false

func activate():
	if animation_player.is_playing():
		return

	self.active = true
	animation_player.play("Activate")

func deactivate():
	if animation_player.is_playing():
		return

	active = false
	animation_player.play("Deactivate")

func _on_Effect_expired(effect : Effect):
	effects.erase(effect)
