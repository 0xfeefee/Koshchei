
Texture_Id :: s16;
Sprite_Id  :: s16;

Sprite :: struct {
	texture: Texture_Id;
	rect: rl.Rectangle;
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
			x= x,
			y= y,
			width= width,
			height= height
		}
	};

	return sprite_id;
}

get_texture :: inline (id: Texture_Id) -> *rl.Texture {
	return static_pool_get(_texture_storage, id);
}

#scope_module
_texture_storage: *Static_Pool(rl.Texture, MAX_TEXTURE_COUNT);
_sprite_storage: *Static_Pool(rl.Texture, MAX_SPRITE_COUNT);
