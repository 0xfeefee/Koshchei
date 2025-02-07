
Shader_Id :: s16;

create_shader :: (vertex_source: string = "", fragment_source: string = "") -> Shader_Id #must {
	shader, shader_id := static_pool_new(_shader_storage);
	shader.* = rl.LoadShaderFromMemory(vertex_source.data, fragment_source.data);

	return shader_id;
}

uniform_location :: (id: Shader_Id, uniform_name: string) -> s32 #must {
	shader := static_pool_get(_shader_storage, id);

	return rl.GetShaderLocation(shader, uniform_name.data);
}

set_uniform :: (id: Shader_Id, uniform_location: s32, value: $T) {
	shader := static_pool_get(_shader_storage, id);

	shader_value := cast(*void, value);
	shader_type: s32;
	if T == {
		case *float; shader_type = cast(s32, rl.ShaderUniformDataType.FLOAT);
		case *Vec2;  shader_type = cast(s32, rl.ShaderUniformDataType.VEC2);
		case;
	};

	rl.SetShaderValue(shader, uniform_location, shader_value, shader_type);
}

begin_shader :: (id: Shader_Id) #expand {
	shader: *rl.Shader = static_pool_get(_shader_storage, id);

	rl.BeginShaderMode(shader);
	`defer rl.EndShaderMode();
}

#scope_module
_shader_storage: *Static_Pool(rl.Shader, MAX_SHADER_COUNT);
