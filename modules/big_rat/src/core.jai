
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

#scope_file
current_config: Config;
