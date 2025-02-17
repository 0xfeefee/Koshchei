
Vec2 :: rl.Vector2;
Vec3 :: rl.Vector3;
Vec4 :: rl.Vector4;

Camera_Id :: s16;

Camera_Up :: enum u8 {
	Y_UP;
	Z_UP;
	X_UP;
	Z_DOWN;
};

camera_up_to_vec3 :: (up: Camera_Up) -> Vec3 {
	if up == {
		case .Y_UP;   return .{ 0, 1, 0 };
		case .Z_UP;   return .{ 0, 0, 1 };
		case .Z_DOWN; return .{ 0, 0, -1 };
		case; return .{ 1, 0, 0 };
	};

	// return .{ 1, 0, 0 };
}

create_camera :: (camera_position: Vec3, fov: float = 0, up: Camera_Up = .Z_DOWN) -> Camera_Id {
	// if FOV is greater than 0 we use PERSPECTIVE projection:
	camera_projection: s32 = cast(s32)ifx fov > 0 rl.CameraProjection.PERSPECTIVE else rl.CameraProjection.ORTHOGRAPHIC;

	vec_up: Vec3 = camera_up_to_vec3(up);

	camera, camera_id := static_pool_new(_camera_storage);
	camera.* = rl.Camera.{
		position= 	camera_position,
		target=   	.{ 0.0, 0.0, 0.0 },
		up=       	vec_up, // Same as blender!
		fovy= 	  	fov,
		projection= camera_projection
	};

	return camera_id;
}

get_camera :: (camera_id: Camera_Id) -> *rl.Camera {
	return static_pool_get(_camera_storage, camera_id);
}

begin_camera :: (id: Camera_Id) #expand {
	camera: *rl.Camera = static_pool_get(_camera_storage, id);
	rl.BeginMode3D(camera.*);

	`defer rl.EndMode3D();
}

#scope_module
_camera_storage: *Static_Pool(rl.Camera, MAX_CAMERA_COUNT) = ---;
