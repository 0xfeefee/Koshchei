
gen_mesh_plane :: (width: f32, length: f32, $dim_x: u8 = 1, $dim_z: u8 = 1) -> rl.Mesh {
	/*
		Constants
	*/
	res_x:   u8  : dim_x + 1;
	res_z:   u8  : dim_z + 1;
	v_count: s16 : res_x * res_z;
	f_count: s16 : (res_x - 1) * (res_z - 1);

	Plane_Mesh_Data :: struct {
		vertices:  [v_count * 3]f32;
		normals:   [v_count * 3]f32;
		texcoords: [v_count * 2]f32;
		indices:   [f_count * 6]u16;
	};

	// Allocate all mesh data at once:
	using data: *Plane_Mesh_Data = New(Plane_Mesh_Data);

	// Vertices:
	for z: 0..res_z-1 {
		z_pos: f32 = (z / (res_z - 1) - 0.5) * length;
		for x: 0..res_x-1 {
			x_pos: f32 = (x / (res_x - 1) - 0.5) * width;

			i 				:= x * 3 + z * 3 * res_x;
			vertices[i]     = x_pos;
			vertices[i + 1] = 0.0;
			vertices[i + 2] = z_pos;
		}
	}

	// Normals:
	for n: 0..v_count-1 {
		normals[n * 3 + 1] = 1.0;
	}

	// Texture coordinates:
	for v: 0..res_z-1 {
		for u: 0..res_x-1 {
			i := u * 2 + v * 2 * res_x;

			texcoords[i]     = cast(f32, u / (res_x-1));
			texcoords[i + 1] = cast(f32, v / (res_z-1));
		}
	}

	// Indices:
	for face: 0..f_count-1 {
		i: u16 = cast(u16, face + face / (res_x - 1));
		f := face * 6;

		indices[f]     = i + res_x;
		indices[f + 1] = i + 1;
		indices[f + 2] = i;

		indices[f + 3] = i + res_x;
		indices[f + 4] = i + res_x + 1;
		indices[f + 5] = i + 1;
	}

	// Just for now...
	return rl.Mesh.{
		vertexCount=   v_count,
		triangleCount= f_count * 2,
		vertices=      vertices.data,
		normals=       normals.data,
		texcoords=     texcoords.data,
		indices=       indices.data
	};
}
