
#import "big_rat";

WINDOW_WIDTH  :: 1920;
WINDOW_HEIGHT :: 1080;
FRAME_WIDTH   :: WINDOW_WIDTH/4;
FRAME_HEIGHT  :: WINDOW_HEIGHT/4;
FRAMERATE     :: 144;
CLEAR_COLOR   :: rl.Color.{ 20, 20, 20, 255 };

using rl;

main :: () {
	// Create the main window and initialize all the systems:
	init(.{
		window_width=     WINDOW_WIDTH,
		window_height=    WINDOW_HEIGHT,
		frame_width=      FRAME_WIDTH,
		frame_height=     FRAME_HEIGHT,
		title=            PROJECT_INFO_STRING,
		framerate=        FRAMERATE,
		background=       .{ 50, 50, 50, 255 }
	});

	// Initialize the camera:
	cameras: [3]Camera_Id;
	cameras[0] = create_camera(.{0, 10, 0}, 45);
	cameras[1] = create_camera(.{0, 15, -4}, 45, up=.Z_UP);
	cameras[2] = create_camera(.{10, 0, -4}, 45, up=.Y_UP);

	camera_counter := 0;
	current_camera := cameras[camera_counter];

	// Camera switch input:
	camera_switch := create_input(Keyboard_Button.J, .PRESS);

	// Textures for the card back and front:
	card_front := load_texture("../assets/Card_Texture_front.png");
	card_back  := load_texture("../assets/Card_Texture_back.png");

	// Atlas:
	card_atlas := load_texture("../assets/Card_Texture_Atlas.png");
	sprites: [..]Sprite_Id;

	width: s32  : 256;
	height: s32 : 384;

	for 0..3 {
		x, y: s32;
		x = cast(s32, it) * width;
		y = 0;

		sprite_id := create_sprite(card_atlas, x, y, width, height);
		array_add(*sprites, sprite_id);
	}

	// Card face is just a quad (plane):
	card_mesh  := gen_mesh_plane(2.0, 3.0, 1, 1);
	set_texture_uvs_from_sprite(*card_mesh, sprites[0]);

	card_mesh2 := gen_mesh_plane(2.0, 3.0, 1, 1);
	set_texture_uvs_from_sprite(*card_mesh2, sprites[1]);

	a: *Mesh = *card_mesh;
	b: *Mesh = *card_mesh2;

	UploadMesh(a, false);
	UploadMesh(b, false);

	// Front face:
	card_frontface := create_model(card_mesh);
	set_texture_from_sprite(card_frontface, sprites[0]);

	// Back face:
	card_backface := create_model(card_mesh2);
	set_texture_from_sprite(card_backface, sprites[1]);

	// State:
	rotation_angle: f32;

	// Run the main loop:
	while should_run() {
		// Camera switch:
		update_inputs();
		if check_input(camera_switch) {
			camera_counter += 1;
			current_camera = cameras[camera_counter % cameras.count];
		}

		rotation_angle += 100 * GetFrameTime();

		// Render:
		begin_drawing(); {
			// Grid and main scene:
			draw_screen_grid(32, 32);
			begin_camera(current_camera); {
				draw_card(card_front, card_back, rotation_angle);
			}
		}
	}
}

#import "Basic";
#load "card.jai";
