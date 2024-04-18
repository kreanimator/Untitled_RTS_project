extends Control

var is_rect_visible : bool = false
var m_pos : Vector2
var start_pos : Vector2

const sel_box_color : Color = Color.CHARTREUSE
const sel_box_line_width : int = 4


func _draw():
	if is_rect_visible and start_pos != m_pos:
		var rect := Rect2(Vector2(m_pos.x, m_pos.y), Vector2(start_pos.x -m_pos.x,start_pos.y -m_pos.y))
		draw_rect(rect, sel_box_color, false, sel_box_line_width)
		
func _process(_delta: float) -> void:
	queue_redraw()
