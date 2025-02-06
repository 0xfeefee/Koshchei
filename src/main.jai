
#import "big_rat";

WINDOW_WIDTH  :: 1920;
WINDOW_HEIGHT :: 1080;
CLEAR_COLOR   :: rl.Color.{ 20, 20, 20, 255 };

VS_SOURCE :: #string SHADER_END

SHADER_END

FS_SOURCE :: #string SHADER_END
#version 330

// Raylib specific:
in vec2 			fragTexCoord;
in vec4 			fragColor;

uniform sampler2D 	texture0;
uniform vec4 		colDiffuse;

out vec4 finalColor;

// Custom:
const float   render_width  = 1920;
const float   render_height = 1080;

uniform float angle;
uniform float radius;
uniform vec2  center = vec2(render_width/2, render_height/2);


void main() {
    vec2 tex_size = vec2(render_width, render_height);
    vec2 tc 	  = fragTexCoord * tex_size;
    tc 			 -= center;

    float dist = length(tc);

    if (dist < radius) {
        float percent = (radius - dist)/radius;
        float theta   = percent * percent * angle * 8.0;
        float s 	  = sin(theta);
        float c 	  = cos(theta);

        tc = vec2(dot(tc, vec2(c, -s)), dot(tc, vec2(s, c)));
    }

    tc 		  += center;

    vec4 color = texture(texture0, tc/tex_size) * colDiffuse * fragColor;
    color.z    = abs(sin(color.z * radius/100));

    finalColor = vec4(color.rgb, 1.0);
}
SHADER_END

using rl;

main :: () {
	init(.{
		width= 1920,
		height= 1080,
		title= PROJECT_INFO_STRING,
		framerate= 144,
	});

	// Initialize the camera:
	camera  := create_camera(.{0, 10, 0}, 45);
	camera2 := create_camera(.{0, 12, -4}, 45);

	// State:
	rotation_angle: f32;
	angle: f32 = 0.25;
	range: f32 = 125.0;
	swirl_center: Vector2 = .{ WINDOW_WIDTH / 2.0, WINDOW_HEIGHT / 2.0 };
	camera_counter: int = 0;

	// Texture:
	// @note: We messed up the UV directions, they need to be flipped, but fine for now!.
	card_texture := LoadTexture("../assets/uv_Playing_Card_Y1.png");
	card := LoadModel("../assets/b_Playing_Card_Y1.obj");
	card.materials[0].maps[xx MaterialMapIndex.ALBEDO].texture = card_texture;

	// Setup render texture:
	frame_texture: RenderTexture = LoadRenderTexture(WINDOW_WIDTH, WINDOW_HEIGHT);
	frame_shader := create_shader(fragment_source= FS_SOURCE);

	u_center := uniform_location(frame_shader, "center");
	u_angle  := uniform_location(frame_shader, "angle");
	u_range  := uniform_location(frame_shader, "radius");

	// Run the main loop:
	while should_run() {
		// Start:
		BeginDrawing();
		BeginTextureMode(frame_texture);
		ClearBackground(CLEAR_COLOR);

		mouse_pos   := GetMousePosition();
		mouse_delta := GetMouseDelta();

		if mouse_delta.x > 0 || mouse_delta.y > 0 {
			angle += GetFrameTime()*0.25;
			range += GetFrameTime()*88;
		} else {
			angle *= 0.995;
			range *= 0.999;
		}

		swirl_center.x = mouse_pos.x;
		swirl_center.y = mouse_pos.y;

		set_uniform(frame_shader, u_center, *swirl_center);
		set_uniform(frame_shader, u_angle, *angle);
		set_uniform(frame_shader, u_range, *range);

		// Draw the background elements
		for i: 0..90 {
			for k: 0..50 {
				DrawCircleV(.{i*25.0, k*25.0}, 4.0, .{40,40,40,255});
			}
		}

		camera_counter += 1;
		if camera_counter > 256 {
			camera_counter = -256;
		}

		// Draw the 3D elements:
		{
			begin_camera(ifx camera_counter > 0 then camera else camera2);
			DrawModelEx(
				card,
				.{ 0.0, 0.0, 0.0 },
			   	.{ 0.0, 0.0, 1.0 },
			   	rotation_angle,
			    .{ 1.0, 1.0, 1.0 },
			    .{ 255, 255, 255, 255 }
			);
		}
		EndTextureMode();

		// Apply post-processing:
		{
			begin_shader(frame_shader);
			DrawTexture(frame_texture.texture, 0, 0, .{255,255,255,255});
		}

		rotation_angle += 100 * GetFrameTime();

		// End:
		EndDrawing();
	}
}

#import "Basic";
