extends MarginContainer

var index := 0
var selected := false

signal clicked(action_index)

func _ready():
    connect("gui_input", self, "_on_gui_input")

func init(name : String, overview : String, p_index : int): 
    $Background/Name.text = name
    $Background/Overview.text = overview
    index = p_index

func _on_gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            emit_signal("clicked", index)

func set_selected(state : bool):
    selected = state
    if selected:
        $Background/Highlight.show()
    else:
        $Background/Highlight.hide()