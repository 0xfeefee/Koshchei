/*
	Simple utils which are useful for development!
*/

draw_screen_grid :: (cell_width: s32, cell_height: s32) {
	size : s32x2 = .{ rl.GetScreenWidth(), rl.GetScreenHeight() };

	rows:    int = size.x/cell_width;
	columns: int = size.y/cell_height;

	color: rl.Color = .{ 60, 60, 60, 255 };

	for x: 0..rows {
		rl.DrawLine(cast(s32, x*cell_width), 0, cast(s32, x*cell_width), cast(s32, size.y), color);
	}

	for y: 0..columns {
		rl.DrawLine(0, cast(s32, y*cell_height), cast(s32, size.x), cast(s32, y*cell_height), color);
	}
}
