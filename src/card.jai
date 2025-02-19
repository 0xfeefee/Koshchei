
draw_card :: (front: Model_Id, back: Model_Id, rotation_angle: float) {
	front_model := get_model(front);
	assert(front_model != null);
	DrawModelEx(
		front_model,
		.{ 0.0, 0.0, 0.0 },
	   	.{ 0.0, 0.0, 1.0 },
	   	rotation_angle-180.0,
	    .{ 1.0, 1.0, 1.0 },
	    .{ 255, 255, 255, 255 }
	);

	back_model  := get_model(back);
	assert(back_model != null);
	DrawModelEx(
		back_model,
		.{ 0.0, 0.0, 0.0 },
	   	.{ 0.0, 0.0, 1.0 },
	   	rotation_angle,
	    .{ 1.0, 1.0, 1.0 },
	    .{ 255, 255, 255, 255 }
	);
}
