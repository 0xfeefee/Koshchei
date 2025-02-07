
Model_Id :: s16;

load_model :: (model_file_name: string) -> Model_Id {
	model, model_id := static_pool_new(_model_storage);
	model.* = rl.LoadModel(model_file_name.data);

	return model_id;
}

set_texture :: (model_id: Model_Id, texture_id: Texture_Id) {
	model := static_pool_get(_model_storage, model_id);
	model.materials[0].maps[cast(int, rl.MaterialMapIndex.ALBEDO)].texture = static_pool_get(_texture_storage, texture_id);
}

get_model :: (model_id: Model_Id) -> *rl.Model {
	return static_pool_get(_model_storage, model_id);
}

#scope_module
_model_storage: *Static_Pool(rl.Model, MAX_MODEL_COUNT);
