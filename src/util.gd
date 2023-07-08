class_name Util


static func rank_to_texture(rank: int) -> Texture2D:
	if rank == 1:
		return preload("res://assets/ranks/rank_1.png")
	elif rank == 2:
		return preload("res://assets/ranks/rank_2.png")
	elif rank == 3:
		return preload("res://assets/ranks/rank_3.png")
	elif rank == 4:
		return preload("res://assets/ranks/rank_4.png")
	else:
		push_error("Invalid rank %d" % rank)
		return
