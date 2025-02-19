
Model_Id :: s16;

load_model :: (model_file_name: string) -> Model_Id {
	model, model_id := static_pool_new(_model_storage);
	model.* = rl.LoadModel(model_file_name.data);

	return model_id;
}

create_model :: (mesh: rl.Mesh) -> Model_Id {
	model, model_id := static_pool_new(_model_storage);
	model.* = rl.LoadModelFromMesh(mesh);

	return model_id;
}

set_texture :: (model_id: Model_Id, texture_id: Texture_Id) {
	model := static_pool_get(_model_storage, model_id);
	model.materials[0].maps[cast(int, rl.MaterialMapIndex.ALBEDO)].texture = static_pool_get(_texture_storage, texture_id);
}

set_texture_from_sprite :: (model_id: Model_Id, sprite_id: Sprite_Id) {
	model := static_pool_get(_model_storage, model_id);
	assert(model != null);

	sprite := static_pool_get(_sprite_storage, sprite_id);
	assert(sprite != null);

	model.materials[0].maps[cast(int, rl.MaterialMapIndex.ALBEDO)].texture = static_pool_get(_texture_storage, sprite.texture);
}

// set_texture_from_sprite :: (model_id: Model_Id, sprite: Sprite_Id) {
// 	model  := static_pool_get(_model_storage, model_id);
// 	sprite := static_pool_get(_sprite_storage, model_id);

// 	model.materials[0].maps[cast(int, rl.MaterialMapIndex.ALBEDO)].texture = static_pool_get(_texture_storage, sprite.texture);

// 	// Update mesh UV's to match the subtexture rect:
// 	rect := sprite.rect;
// 	mesh := *model.meshes[0];

// 	vcount := mesh.vertexCount*2;
// 	atlas_width := 1024;
// 	atlas_height := 384;
// 	i: s32 = 0;

// 	for 0..vcount {
// 		u: f32 = mesh.texcoords[i];
// 		v: f32 = mesh.texcoords[i + 1];

// 		mesh.texcoords[i]     = rect.x / atlas_width + (u * rect.width / atlas_width);
// 		mesh.texcoords[i + 1] = rect.y / atlas_height + (v * rect.height / atlas_height);

// 		i += 2;
// 	}

// 	// rl.UpdateMeshBuffer(mesh, 1, mesh.texcoords, size_of(f32) * 2 * mesh.vertexCount, 0);
// }

get_model :: (model_id: Model_Id) -> *rl.Model {
	return static_pool_get(_model_storage, model_id);
}

#scope_module
_model_storage: *Static_Pool(rl.Model, MAX_MODEL_COUNT);
