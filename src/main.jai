
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

gen_triangle_mesh :: () -> Mesh {
	mesh := gen_mesh_base(triangle_count= 1);

	// Vertex at (0, 0, 0):
    mesh.vertices[0] = 0;
    mesh.vertices[1] = 0;
    mesh.vertices[2] = 0;
    mesh.normals[0]  = 0;
    mesh.normals[1]  = 1;
    mesh.normals[2]  = 0;
    mesh.texcoords[0] = 0;
    mesh.texcoords[1] = 0;

    // Vertex at (1, 0, 2)
    mesh.vertices[3] = 1;
    mesh.vertices[4] = 0;
    mesh.vertices[5] = 2;
    mesh.normals[3] = 0;
    mesh.normals[4] = 1;
    mesh.normals[5] = 0;
    mesh.texcoords[2] = 0.5;
    mesh.texcoords[3] = 1.0;

    // Vertex at (2, 0, 0)
    mesh.vertices[6] = 2;
    mesh.vertices[7] = 0;
    mesh.vertices[8] = 0;
    mesh.normals[6] = 0;
    mesh.normals[7] = 1;
    mesh.normals[8] = 0;
    mesh.texcoords[4] = 1;
    mesh.texcoords[5] = 0;

    UploadMesh(*mesh, false);
	return mesh;
}

gen_mesh_base :: (triangle_count: s32) -> Mesh {
	mesh: Mesh;
	mesh.triangleCount = triangle_count;
	mesh.vertexCount   = triangle_count * 3;
	mesh.vertices      = cast(*float, MemAlloc(cast(u32, mesh.vertexCount * 3 * size_of(float))));
	mesh.texcoords     = cast(*float, MemAlloc(cast(u32, mesh.vertexCount * 2 * size_of(float))));
	mesh.normals       = cast(*float, MemAlloc(cast(u32, mesh.vertexCount * 3 * size_of(float))));

	return mesh;
}

gen_mesh_plane :: (width: f32, length: f32, res_x: s32, res_z: s32) -> Mesh {
	// Create mesh:
	mesh: Mesh;

	res_x += 1; // resX++
	res_z += 1; // resY++

 	// Vertices definition:
	vertex_count: s32 = res_x * res_z;
	vertices: *Vector3 = cast(*Vector3)MemAlloc(cast(u32, vertex_count * size_of(Vector3)));

	for z: 0..(res_z-1) {
		z_pos: f32 = (z / (res_z - 1) - 0.5) * length;

		for x: 0..(res_x -1) {
			x_pos: f32 = (x / (res_x - 1) - 0.5) * width;
			vertices[x + z * res_x] = Vector3.{ x_pos, 0.0, z_pos };
		}
	}

	// Normals definition:
	normals: *Vector3 = cast(*Vector3)MemAlloc(cast(u32, vertex_count * size_of(Vector3)));
	for n: 0..(vertex_count-1) {
		normals[n] = Vector3.{ 0.0, 1.0, 0.0 };
	}

	// TexCoords definitions:
	texcoords: *Vector2 = cast(*Vector2)MemAlloc(cast(u32, vertex_count * size_of(Vector2)));
	for v: 0..(res_z-1) {
		for u: 0..(res_x-1) {
			texcoords[u + v * res_x] = Vector2.{ cast(float, u/(res_x-1)), cast(float, v/(res_z-1)) };
		}
	}

	// Triangles definitions (indices):
	num_faces: s32  = (res_x - 1) * (res_z - 1);
	triangles: *s32 = cast(*s32)MemAlloc(cast(u32, num_faces * 6 * size_of(int)));
	t:         s32  = 0;

	for face: 0..(num_faces-1) {
		i: s32 = face + face / (res_x - 1);

		triangles[t] = i + res_x;
		t += 1;
		triangles[t] = i + 1;
		t += 1;
		triangles[t] = i;
		t += 1;

		triangles[t] = i + res_x;
		t += 1;
		triangles[t] = i + res_x + 1;
		t += 1;
		triangles[t] = i + 1;
		t += 1;
	}

	mesh.vertexCount   = vertex_count;
	mesh.triangleCount = num_faces * 2;
	mesh.vertices      = cast(*float, vertices);
	mesh.normals       = cast(*float, normals);
	mesh.texcoords     = cast(*float, texcoords);
	mesh.indices       = cast(*u16, triangles);

	for i: 0..(mesh.triangleCount * 3 - 1) {
		mesh.indices[i] = cast(u16)triangles[i];
	}

	// Just for now...
	return mesh;
}

#import "Basic";
#load "card.jai";
