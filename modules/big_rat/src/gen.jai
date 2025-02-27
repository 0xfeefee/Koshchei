
gen_mesh_plane :: (width: f32, length: f32) -> rl.Mesh {
	/*
		Constants
	*/
	res_x:   s8  : 2;
	res_z:   s8  : 2;
	v_count: s16 : res_x * res_z;
	f_count: s16 : (res_x - 1) * (res_z - 1) * 6;

	Plane_Mesh_Data :: struct {
		vertices:  [v_count * 3]f32;
		normals:   [v_count * 3]f32;
		texcoords: [v_count * 2]f32;
		indices:   [f_count]u16;
	};

	data: *Plane_Mesh_Data = New(Plane_Mesh_Data);
	vertices: *f32 = data.vertices.data;

	for z: 0..res_z-1 {
		z_pos: f32 = (z / (res_z - 1) - 0.5) * length;

		for x: 0..res_x-1 {
			x_pos: f32 = (x / (res_x - 1) - 0.5) * width;

			i := x * 3 + z * 3 * res_x;

			vertices[i]     = x_pos;
			vertices[i + 1] = 0.0;
			vertices[i + 2] = z_pos;
		}
	}

	// Normals definition:
	normals: *f32 = data.normals.data;
	for n: 0..v_count {
		i := n * 3;

		normals[i]     = 0.0;
		normals[i + 1] = 1.0;
		normals[i + 2] = 0.0;
	}

	// TexCoords definitions:
	texcoords: *f32 = data.texcoords.data;
	for v: 0..res_z-1 {
		for u: 0..res_x-1 {
			i := u * 2 + v * 2 * res_x;

			texcoords[i]     = cast(f32, u / (res_x-1));
			texcoords[i + 1] = cast(f32, v / (res_z-1));
		}
	}

	// Triangles definitions (indices):
	res_xs   : u16   = cast(u16, res_x);
	num_faces: s32   = (res_x - 1) * (res_z - 1);
	t:         u16   = 0;

	indices: *u16 = data.indices.data;

	for face: 0..(num_faces-1) {
		i: u16 = cast(u16, face + face / (res_x - 1));

		indices[t] = i + res_xs;
		t += 1;
		indices[t] = i + 1;
		t += 1;
		indices[t] = i;
		t += 1;

		indices[t] = i + res_xs;
		t += 1;
		indices[t] = i + res_xs + 1;
		t += 1;
		indices[t] = i + 1;
		t += 1;
	}

	// Create mesh:
	mesh: rl.Mesh;
	mesh.vertexCount   = v_count;
	mesh.triangleCount = num_faces * 2;
	mesh.vertices      = cast(*float, vertices);
	mesh.normals       = cast(*float, normals);
	mesh.texcoords     = cast(*float, texcoords);
	mesh.indices       = indices;

	// Just for now...
	return mesh;
}



gen_mesh_plane2 :: (width: f32, length: f32, res_x: s32, res_z: s32) -> rl.Mesh {
	// Create mesh:
	mesh: rl.Mesh;

	res_x += 1; // resX++
	res_z += 1; // resY++

	// Plane_Mesh_Data :: struct($VERTEX_COUNT: s16) {
	// 	vertices: [VERTEX_COUNT * 3]float;
	// };

 	// Vertices definition:
	vertex_count: s32   = res_x * res_z;

	// data: *Plane_Mesh_Data = New(Plane_Mesh_Data(xx vertex_count));

	vertices:     *Vec3 = alloc(vertex_count * size_of(Vec3));

	for z: 0..(res_z-1) {
		z_pos: f32 = (z / (res_z - 1) - 0.5) * length;

		for x: 0..(res_x -1) {
			x_pos: f32 = (x / (res_x - 1) - 0.5) * width;
			vertices[x + z * res_x] = Vec3.{ x_pos, 0.0, z_pos };
		}
	}

	// Normals definition:
	normals: *Vec3 = alloc(vertex_count * size_of(Vec3));
	for n: 0..(vertex_count-1) {
		normals[n] = Vec3.{ 0.0, 1.0, 0.0 };
	}

	// TexCoords definitions:
	texcoords: *Vec2 = alloc(vertex_count * size_of(Vec2));
	for v: 0..(res_z-1) {
		for u: 0..(res_x-1) {
			texcoords[u + v * res_x] = Vec2.{ cast(float, u/(res_x-1)), cast(float, v/(res_z-1)) };
		}
	}

	// Triangles definitions (indices):
	res_xs   : u16   = cast(u16, res_x);
	num_faces: s32   = (res_x - 1) * (res_z - 1);
	indices:  *u16   = alloc(num_faces * 6 * size_of(s16));
	t:         u16   = 0;

	for face: 0..(num_faces-1) {
		i: u16 = cast(u16, face + face / (res_x - 1));

		indices[t] = i + res_xs;
		t += 1;
		indices[t] = i + 1;
		t += 1;
		indices[t] = i;
		t += 1;

		indices[t] = i + res_xs;
		t += 1;
		indices[t] = i + res_xs + 1;
		t += 1;
		indices[t] = i + 1;
		t += 1;
	}

	mesh.vertexCount   = vertex_count;
	mesh.triangleCount = num_faces * 2;
	mesh.vertices      = cast(*float, vertices);
	mesh.normals       = cast(*float, normals);
	mesh.texcoords     = cast(*float, texcoords);
	mesh.indices       = indices;

	// Just for now...
	return mesh;
}



#scope_file
/*
	Just keeping this here for reference...
*/
gen_mesh_plane_old :: (width: f32, length: f32, res_x: s32, res_z: s32) -> rl.Mesh {
	// Create mesh:
	mesh: rl.Mesh;

	res_x += 1; // resX++
	res_z += 1; // resY++

 	// Vertices definition:
	vertex_count: s32 = res_x * res_z;
	vertices: *Vec3 = cast(*Vec3)rl.MemAlloc(cast(u32, vertex_count * size_of(Vec3)));

	for z: 0..(res_z-1) {
		z_pos: f32 = (z / (res_z - 1) - 0.5) * length;

		for x: 0..(res_x -1) {
			x_pos: f32 = (x / (res_x - 1) - 0.5) * width;
			vertices[x + z * res_x] = Vec3.{ x_pos, 0.0, z_pos };
		}
	}

	// Normals definition:
	normals: *Vec3 = cast(*Vec3)rl.MemAlloc(cast(u32, vertex_count * size_of(Vec3)));
	for n: 0..(vertex_count-1) {
		normals[n] = Vec3.{ 0.0, 1.0, 0.0 };
	}

	// TexCoords definitions:
	texcoords: *Vec2 = cast(*Vec2)rl.MemAlloc(cast(u32, vertex_count * size_of(Vec2)));
	for v: 0..(res_z-1) {
		for u: 0..(res_x-1) {
			texcoords[u + v * res_x] = Vec2.{ cast(float, u/(res_x-1)), cast(float, v/(res_z-1)) };
		}
	}

	// Triangles definitions (indices):
	res_xs   : u16   = cast(u16, res_x);
	num_faces: s32   = (res_x - 1) * (res_z - 1);
	indices:  *u16   = cast(*u16)rl.MemAlloc(cast(u32, num_faces * 6 * size_of(s16)));
	t:         u16   = 0;

	for face: 0..(num_faces-1) {
		i: u16 = cast(u16, face + face / (res_x - 1));

		indices[t] = i + res_xs;
		t += 1;
		indices[t] = i + 1;
		t += 1;
		indices[t] = i;
		t += 1;

		indices[t] = i + res_xs;
		t += 1;
		indices[t] = i + res_xs + 1;
		t += 1;
		indices[t] = i + 1;
		t += 1;
	}

	mesh.vertexCount   = vertex_count;
	mesh.triangleCount = num_faces * 2;
	mesh.vertices      = cast(*float, vertices);
	mesh.normals       = cast(*float, normals);
	mesh.texcoords     = cast(*float, texcoords);
	mesh.indices       = indices;

	// Just for now...
	return mesh;
}
