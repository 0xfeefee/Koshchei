
Vec2 :: rl.Vector2;
Vec3 :: rl.Vector3;
Vec4 :: rl.Vector4;

Camera_Id :: s16;

create_camera :: (camera_position: Vec3, fov: float = 0) -> Camera_Id {
	// if FOV is greater tha	n 0 we use PERSPECTIVE projection:
	camera_projection: s32 = cast(s32)ifx fov > 0 rl.CameraProjection.PERSPECTIVE else rl.CameraProjection.ORTHOGRAPHIC;

	camera, camera_id := static_pool_new(_camera_storage);
	camera.* = rl.Camera.{
		position= 	camera_position,
		target=   	.{ 0.0, 0.0, 0.0 },
		up=       	.{ 0.0, 0.0, 1.0 }, // Same as blender!
		fovy= 	  	fov,
		projection= camera_projection
	};

	return camera_id;
}

begin_camera :: (id: Camera_Id) #expand {
	camera: *rl.Camera = static_pool_get(_camera_storage, id);
	rl.BeginMode3D(camera.*);

	`defer rl.EndMode3D();
}

#scope_module
_camera_storage: *Static_Pool(rl.Camera, MAX_CAMERA_COUNT) = ---;
