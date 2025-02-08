
/*
	I'm aliasing string here because I want to be able to find every instance of asset path such that
	assets can be inlined automatically by the compiler for release builds.
*/
Asset_Path :: string;

s32x2 :: struct {
	x, y: s32;
}

/*
	Used to configure the engine.
	@todo: convert the boolean variables into flags.
*/
Config :: struct {
	width:      s32 		= 640;
	height:     s32 		= 480;
	framerate:  s32 		= 60;
	title:      string 		= "Big_Rat";
	icon_path:  Asset_Path  = "";
	vsync:      bool 		= true;
	fullscreen: bool 		= false;
};

/*
	Initializes the engine.
*/
init :: (using config: Config) #expand {
	init_all_storage();

	// Create and configure the window:
	rl.InitWindow(width, height, title.data);

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

	current_config = config;

	// Initialize the Audio device as well:
	rl.InitAudioDevice();

	// Close everything:
	`defer rl.CloseAudioDevice();
	`defer rl.CloseWindow();
}

should_run :: () -> bool #must {
	return !rl.WindowShouldClose() && !stop_requested;
}

stop :: () {
	stop_requested = true;
}

init_all_storage :: () {
	_camera_storage  = New(Static_Pool(rl.Camera, MAX_CAMERA_COUNT));
	_shader_storage  = New(Static_Pool(rl.Shader, MAX_SHADER_COUNT));
	_texture_storage = New(Static_Pool(rl.Texture, MAX_TEXTURE_COUNT));
	_model_storage   = New(Static_Pool(rl.Model, MAX_MODEL_COUNT));
}


#scope_file
current_config: Config;
stop_requested: bool = false;
