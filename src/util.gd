class_name Util


static func rank_to_texture(rank: int) -> Texture2D:
	if rank == 1:
		return preload("res://assets/ranks/rank_1.png")
	elif rank == 2:
		return preload("res://assets/ranks/rank_2.png")
	elif rank == 3:
		return preload("res://assets/ranks/rank_3.png")
	else:
		push_error("Invalid rank %d" % rank)
		return


static func fit_text(label: Label, max_font_size: int = 16):
	var font_size = max_font_size
	var label_font = label.get_theme_font("font_size")
	while label_font.get_string_size(label.text, label.horizontal_alignment, -1, font_size).x > label.size.x:
		font_size -= 1
	label.add_theme_font_size_override("font_size", font_size)
