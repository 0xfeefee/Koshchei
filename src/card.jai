
draw_card :: (front: rl.Model, back: rl.Model, rotation_angle: float) {
	DrawModelEx(
		front,
		.{ 0.0, 0.0, 0.0 },
	   	.{ 0.0, 0.0, 1.0 },
	   	rotation_angle+180.0,
	    .{ 1.0, 1.0, 1.0 },
	    .{ 255, 255, 255, 255 }
	);
	DrawModelEx(
		back,
		.{ 0.0, 0.0, 0.0 },
	   	.{ 0.0, 0.0, 1.0 },
	   	rotation_angle,
	    .{ 1.0, 1.0, 1.0 },
	    .{ 255, 255, 255, 255 }
	);
}

