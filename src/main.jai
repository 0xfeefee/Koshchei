
#import "big_rat";

WINDOW_WIDTH  :: 1920;
WINDOW_HEIGHT :: 1080;
FRAMERATE     :: 144;
CLEAR_COLOR   :: rl.Color.{ 20, 20, 20, 255 };

using rl;

main :: () {
	// Create the main window and initialize all the systems:
	init(.{
		width=     WINDOW_WIDTH,
		height=    WINDOW_HEIGHT,
		title=     PROJECT_INFO_STRING,
		framerate= FRAMERATE,
	});

	// Initialize the camera:
	camera_a       := create_camera(.{0, 10, 0}, 45);
	camera_b       := create_camera(.{0, 15, -4}, 45, up=.{1, 0, 0});
	current_camera := camera_a;

	// Camera switch input:
	camera_switch := create_input(Keyboard_Button.J, .PRESS);

	// Setup render texture:
	frame_texture: RenderTexture = LoadRenderTexture(WINDOW_WIDTH, WINDOW_HEIGHT);

	// Textures for the card back and front:
	card_front := rl.LoadTexture("../assets/Card_Texture_front.png");
	card_back  := rl.LoadTexture("../assets/Card_Texture_back.png");

	// Card face is just a quad (plane):
	card_mesh := rl.GenMeshPlane(2.0, 3.0, 1, 1);

	// Front face:
	card_frontface := rl.LoadModelFromMesh(card_mesh);
	card_frontface.materials[0].maps[cast(int, rl.MaterialMapIndex.ALBEDO)].texture = card_front;

	// Back face:
	card_backface := rl.LoadModelFromMesh(card_mesh);
	card_backface.materials[0].maps[cast(int, rl.MaterialMapIndex.ALBEDO)].texture = card_back;

	// State:
	rotation_angle: f32;

	// Run the main loop:
	while should_run() {
		// Camera switch:
		update_inputs();
		if check_input(camera_switch) {
			current_camera = ifx current_camera == camera_a then camera_b else camera_a;
		}

		rotation_angle += 100 * GetFrameTime();

		// Render:
		BeginDrawing();
		BeginTextureMode(frame_texture); {
			ClearBackground(CLEAR_COLOR);

			// Grid and main scene:
			draw_screen_grid(32, 32);
			begin_camera(current_camera); {
				draw_card(card_frontface, card_backface, rotation_angle);
			}
		} EndTextureMode();

		// Post process (MIA, no shader atm)
		{
			DrawTexture(frame_texture.texture, 0, 0, .{255,255,255,255});
		}

		// End:
		EndDrawing();
	}
}

#import "Basic";
#load "card.jai";
