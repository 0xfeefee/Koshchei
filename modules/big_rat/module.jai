/*
# big_rat

	2D game module, built on top of Raylib, for quick, fun, and simple game dev.
*/

#load "src/Static_Pool.jai";

#load "src/core.jai";
#load "src/camera.jai";
#load "src/shader.jai";
#load "src/texture.jai";
#load "src/model.jai";
#load "src/debug.jai";

MAX_CAMERA_COUNT  :: 16;
MAX_SHADER_COUNT  :: 8;
MAX_TEXTURE_COUNT :: 16;
MAX_MODEL_COUNT   :: 16;
MAX_SPRITE_COUNT  :: 128;

rl :: #import "raylib_win64";

#scope_module
#import "Basic";
#import "my_util";

BIG_RAT_TEST_DSA :: false;
