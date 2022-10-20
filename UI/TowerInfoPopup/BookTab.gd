extends Button


func tab(var is_tabbed: bool) -> void:
	$ClickedTab.set_visible(is_tabbed)
	$UnclickedTab.set_visible(not is_tabbed)
