extends MarginContainer

var Action_gui = preload("res://Scenes/Action.tscn")
onready var actions = $HBoxContainer/VBoxContainer

signal action_chosen(action_index)

func display_actions(actor : Actor):
	for child in actions.get_children():
		actions.remove_child(child)
	var index = 0
	for action in actor.actions:
		var action_gui = Action_gui.instance()
		action_gui.init(action.name, action.overview, index)
		action_gui.connect("clicked", self, "_on_Action_clicked")
		actions.add_child(action_gui)
		index += 1

	show()

func close():
	hide()
	for child in actions.get_children():
		actions.remove_child(child)

func _on_Action_clicked(index : int):
	emit_signal("action_chosen", index)

func set_selected_action(action_index : int, state : bool):
	actions.get_child(action_index).set_selected(state)
