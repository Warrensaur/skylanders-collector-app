extends ScrollContainer

class_name CollectionScroller

var current_screen_relative: Vector2
var past_screen_relative: Vector2
var past_pos: Vector2
var present_pos: Vector2

var scroll_factor: float = 0.5

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var distance: float
		if !past_screen_relative:
			past_screen_relative = event.get_screen_relative()
		if !past_pos:
			past_pos = event.position
		current_screen_relative = event.get_screen_relative()
		present_pos = event.position
		if past_screen_relative != current_screen_relative:
			distance = past_screen_relative.distance_to(current_screen_relative)
		if past_pos != present_pos:
			if present_pos.y > past_pos.y:
				set("scroll_vertical", lerp(get("scroll_vertical"), int(get_v_scroll() - (distance * 4)), scroll_factor))
			else:
				if present_pos.y < past_pos.y:
					set("scroll_vertical", lerp(get("scroll_vertical"), int(get_v_scroll() + (distance * 4)), scroll_factor))
		past_screen_relative = current_screen_relative
		past_pos = present_pos
