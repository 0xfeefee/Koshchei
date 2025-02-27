
Texture_Id :: s16;
Sprite_Id  :: s16;

Sprite :: struct {
	texture: Texture_Id;
	rect:    rl.Rectangle;
}

load_texture :: (image_file_name: string) -> Texture_Id {
	texture, texture_id := static_pool_new(_texture_storage);
	texture.* = rl.LoadTexture(image_file_name.data);

	return texture_id;
}

create_sprite :: (texture_id: Texture_Id, x: s32, y: s32, width: s32, height: s32) -> Sprite_Id {
	sprite, sprite_id := static_pool_new(_sprite_storage);
	sprite.* = Sprite.{
		texture= texture_id,
		rect= .{
			x= xx x,
			y= xx y,
			width= xx width,
			height= xx height
		}
	};

	return sprite_id;
}

// @heisenbug: UV re-calculations break model upload!
set_texture_uvs_from_sprite :: (mesh: *rl.Mesh, sprite_id: Sprite_Id) {
	//
	assert(mesh != null);
	// Update mesh UV's to match the subtexture rect:
	sprite := get_sprite(sprite_id);
	assert(sprite != null);

	rect := sprite.rect;

	vcount := mesh.vertexCount;
	atlas_width  := 1024.0; // This isn't the full dimensions, but ok..
	atlas_height := 384.0;

	i: s32 = 0;

	for 0..vcount-1 {
		u: f32 = mesh.texcoords[i];
		v: f32 = mesh.texcoords[i + 1];

		// @todo: clean this up a bit...
		u2 := rect.x / atlas_width + (u * rect.width / atlas_width);
		v2 := rect.y / atlas_height + (v * rect.height / atlas_height);

		if (u2 < 0) u2 = 0;
		if (v2 < 0) v2 = 0;

		if (u2 > 1) u2 = 1;
		if (v2 > 1) v2 = 1;

		mesh.texcoords[i]     = u2;
		mesh.texcoords[i + 1] = v2;

		i += 2;
	}
}

get_sprite :: inline (id: Sprite_Id) -> *Sprite {
	return static_pool_get(_sprite_storage, id);
}

get_texture :: inline (id: Texture_Id) -> *rl.Texture {
	return static_pool_get(_texture_storage, id);
}

#scope_module
_texture_storage: *Static_Pool(rl.Texture, MAX_TEXTURE_COUNT);
_sprite_storage: *Static_Pool(Sprite, MAX_SPRITE_COUNT);
