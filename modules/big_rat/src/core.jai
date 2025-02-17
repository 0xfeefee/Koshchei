
/*
	I'm aliasing string here because I want to be able to find every instance of asset path such that
	assets can be inlined automatically by the compiler for release builds.
*/
Asset_Path :: string;


/*
	Used to configure the engine.
	@todo: convert the boolean variables into flags.
*/
Config :: struct {
	window_width:  s32 		   = 640;
	window_height: s32 		   = 480;
	frame_width:   s32         = 0;
	frame_height:  s32         = 0;
	framerate:     s32 		   = 60;
	title:         string 	   = "Big_Rat";
	icon_path:     Asset_Path  = "";
	vsync:         bool 	   = true;
	fullscreen:    bool 	   = false;
	background:    rl.Color    = .{ 255, 255, 255, 255 };
};

/*
	Initializes the engine.
*/
init :: (config: Config) #expand {
	current_config = config;
	using current_config;

	init_all_storage();

	// Create and configure the window:
	rl.InitWindow(window_width, window_height, title.data);

	if vsync {
		rl.SetWindowState(cast(u32, rl.ConfigFlags.VSYNC_HINT));
	}

	if fullscreen {
		if !rl.IsWindowFullscreen() {
			rl.ToggleFullscreen();
		}
	}

	rl.SetTargetFPS(framerate);

	// Set the window icon:
	if icon_path.data != null {
		icon := rl.LoadImage(icon_path.data);
		error_if(icon.data == null, "Unable to load the window icon!");

		rl.SetWindowIcon(icon);
	} else {
		print_warning("Icon was not set!");
	}

	// Setup render texture:
	if frame_width <= 0 || frame_height <= 0 {
		frame_width  = window_width;
		frame_height = window_height;
	}

	frame_texture = rl.LoadRenderTexture(frame_width, frame_height);

	// Initialize the Audio device as well:
	rl.InitAudioDevice();

	// Close everything:
	`defer rl.CloseAudioDevice();
	`defer rl.CloseWindow();
}

should_run :: () -> bool #must {
	return !rl.WindowShouldClose() && !stop_requested;
}

/*
	Start drawing the scene with automatic scope-bound end calls. The scene will be drawn onto a
	{ frame_texture } which can then be used for post-processing.

	@guess: for now I assume we want only one render texture (for post processing).
*/
begin_drawing :: () #expand {
	rl.BeginDrawing();
	rl.BeginTextureMode(frame_texture);
	rl.ClearBackground(current_config.background);

	`defer rl.DrawTexturePro(
		frame_texture.texture,
		.{ 0, 0, cast(float, frame_texture.texture.width), cast(float, -frame_texture.texture.height) },
		.{ 0, 0, cast(float, current_config.window_width), cast(float, current_config.window_height) },
		.{ 0, 0},
		0,
		.{ 255, 255, 255, 255 }
	);

	`defer rl.EndTextureMode();
	`defer rl.EndDrawing();
}

stop :: () {
	stop_requested = true;
}

init_all_storage :: () {
	_camera_storage  = New(Static_Pool(rl.Camera, MAX_CAMERA_COUNT));
	_shader_storage  = New(Static_Pool(rl.Shader, MAX_SHADER_COUNT));
	_texture_storage = New(Static_Pool(rl.Texture, MAX_TEXTURE_COUNT));
	_model_storage   = New(Static_Pool(rl.Model, MAX_MODEL_COUNT));
	_input_mappings  = New(Static_Pool(Input_Mapping, MAX_INPUT_MAPPINGS));
	_sprite_storage  = New(Static_Pool(Sprite, MAX_SPRITE_COUNT));
}

#scope_file
current_config: Config;
stop_requested: bool = false;
frame_texture: rl.RenderTexture;
// resolutions: