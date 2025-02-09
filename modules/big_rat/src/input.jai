
/*
# Big Rat: Input

	Inputs also use the palette system, you can create inputs in the palette and at any point you can change
	those inputs with the given handle. This system is really good for most inputs, it will not handle the fine
	axis inputs and it does not handle mouse position.

	- { create_input }: add a new input mapping to the input palette. It takes an id of an input - button or axis
	  and the input check type. Which determines the condition which the input must satisfy in order to qualify
	  as activated during { update_inputs }.
	- { update_inputs }: update every single input mapping activation value - call once per frame.
	- { check_input }: check if the given input is activated.
	- { get_mouse_position }: get the current mouse position, this is a special case in that there's no mapping
	  for mouse movement.
	- { check_mouse_intersects }: check if mouse is intersecting a rectangle.
*/
Input_Mapping_Id :: s16;

s32x2 :: struct {
	x, y: s32;
}

Input_Mapping :: struct {
	target: s32; 		// Button, Key, Axis
	type: Check_Type;   // PRESS, RELEASE, DOWN || MIN, MAX, etc.
	value: bool;
}

/* Input check types: */
Key_Check_Type :: enum u8 {
	DOWN    :: Check_Type.KEY_DOWN;
	PRESS 	:: Check_Type.KEY_PRESS;
	RELEASE :: Check_Type.KEY_RELEASE;
}

Mouse_Button_Check_Type :: enum u8 {
	DOWN 	:: Check_Type.MOUSE_DOWN;
	PRESS   :: Check_Type.MOUSE_PRESS;
	RELEASE :: Check_Type.MOUSE_RELEASE;
}

Gamepad_Button_Check_Type :: enum u8 {
	DOWN    :: Check_Type.GAMEPAD_DOWN;
	PRESS 	:: Check_Type.GAMEPAD_PRESS;
	RELEASE :: Check_Type.GAMEPAD_RELEASE;
}

Gamepad_Axis_Check_Type :: enum u8 {
	MIN 		 :: Check_Type.GAMEPAD_AXIS_MIN;
	MIN_NEGATIVE :: Check_Type.GAMEPAD_AXIS_MIN_NEGATIVE;
}

Mouse_Axis_Check_Type :: enum u8 {
	MIN  		 :: Check_Type.MOUSE_AXIS_MIN;
	MIN_NEGATIVE :: Check_Type.MOUSE_AXIS_MIN_NEGATIVE;
}

// Enums:
Origin_Type :: enum u8 {
	TOP_LEFT :: 0;
	CENTER;
}

/* Input types: */
Gamepad_Axis :: enum s16 {
	LEFT_X        :: 0;
	LEFT_Y        :: 1;
	RIGHT_X       :: 2;
	RIGHT_Y       :: 3;
	LEFT_TRIGGER  :: 4;
	RIGHT_TRIGGER :: 5;
}

Mouse_Axis :: enum s16 {
	Y :: 0;
}

Gamepad_Button :: enum s16 {
	UNKNOWN          :: 0;
	LEFT_FACE_UP     :: 1;
	LEFT_FACE_RIGHT  :: 2;
	LEFT_FACE_DOWN   :: 3;
	LEFT_FACE_LEFT   :: 4;
	RIGHT_FACE_UP    :: 5;
	RIGHT_FACE_RIGHT :: 6;
	RIGHT_FACE_DOWN  :: 7;
	RIGHT_FACE_LEFT  :: 8;
	LEFT_TRIGGER_1   :: 9;
	LEFT_TRIGGER_2   :: 10;
	RIGHT_TRIGGER_1  :: 11;
	RIGHT_TRIGGER_2  :: 12;
	MIDDLE_LEFT      :: 13;
	MIDDLE           :: 14;
	MIDDLE_RIGHT     :: 15;
	LEFT_THUMB       :: 16;
	RIGHT_THUMB      :: 17;
}

// Mouse buttons
Mouse_Button :: enum s16 {
	LEFT    :: 0;
	RIGHT   :: 1;
	MIDDLE  :: 2;
	SIDE    :: 3;
	EXTRA   :: 4;
	FORWARD :: 5;
	BACK    :: 6;
}

// Input:
Keyboard_Button :: enum s16 {
	NULL          :: 0;

	APOSTROPHE    :: 39;
	COMMA         :: 44;
	MINUS         :: 45;
	PERIOD        :: 46;
	SLASH         :: 47;
	ZERO          :: 48;
	ONE           :: 49;
	TWO           :: 50;
	THREE         :: 51;
	FOUR          :: 52;
	FIVE          :: 53;
	SIX           :: 54;
	SEVEN         :: 55;
	EIGHT         :: 56;
	NINE          :: 57;
	SEMICOLON     :: 59;
	EQUAL         :: 61;
	A             :: 65;
	B             :: 66;
	C             :: 67;
	D             :: 68;
	E             :: 69;
	F             :: 70;
	G             :: 71;
	H             :: 72;
	I             :: 73;
	J             :: 74;
	K             :: 75;
	L             :: 76;
	M             :: 77;
	N             :: 78;
	O             :: 79;
	P             :: 80;
	Q             :: 81;
	R             :: 82;
	S             :: 83;
	T             :: 84;
	U             :: 85;
	V             :: 86;
	W             :: 87;
	X             :: 88;
	Y             :: 89;
	Z             :: 90;
	LEFT_BRACKET  :: 91;
	BACKSLASH     :: 92;
	RIGHT_BRACKET :: 93;
	GRAVE         :: 96;

	SPACE         :: 32;
	ESCAPE        :: 256;
	ENTER         :: 257;
	TAB           :: 258;
	BACKSPACE     :: 259;
	INSERT        :: 260;
	DELETE        :: 261;
	RIGHT         :: 262;
	LEFT          :: 263;
	DOWN          :: 264;
	UP            :: 265;
	PAGE_UP       :: 266;
	PAGE_DOWN     :: 267;
	HOME          :: 268;
	END           :: 269;
	CAPS_LOCK     :: 280;
	SCROLL_LOCK   :: 281;
	NUM_LOCK      :: 282;
	PRINT_SCREEN  :: 283;
	PAUSE         :: 284;
	F1            :: 290;
	F2            :: 291;
	F3            :: 292;
	F4            :: 293;
	F5            :: 294;
	F6            :: 295;
	F7            :: 296;
	F8            :: 297;
	F9            :: 298;
	F10           :: 299;
	F11           :: 300;
	F12           :: 301;
	LEFT_SHIFT    :: 340;
	LEFT_CONTROL  :: 341;
	LEFT_ALT      :: 342;
	LEFT_SUPER    :: 343;
	RIGHT_SHIFT   :: 344;
	RIGHT_CONTROL :: 345;
	RIGHT_ALT     :: 346;
	RIGHT_SUPER   :: 347;
	KB_MENU       :: 348;

	KP_0          :: 320;
	KP_1          :: 321;
	KP_2          :: 322;
	KP_3          :: 323;
	KP_4          :: 324;
	KP_5          :: 325;
	KP_6          :: 326;
	KP_7          :: 327;
	KP_8          :: 328;
	KP_9          :: 329;
	KP_DECIMAL    :: 330;
	KP_DIVIDE     :: 331;
	KP_MULTIPLY   :: 332;
	KP_SUBTRACT   :: 333;
	KP_ADD        :: 334;
	KP_ENTER      :: 335;
	KP_EQUAL      :: 336;

	BACK          :: 4;
	MENU          :: 82;
	VOLUME_UP     :: 24;
	VOLUME_DOWN   :: 25;
}

create_input :: (button: Keyboard_Button, check_type: Key_Check_Type) -> Input_Mapping_Id {
	return create_input_mapping(cast(s32)button, cast(u8)check_type);
}

create_input :: (button: Mouse_Button, check_type: Mouse_Button_Check_Type) -> Input_Mapping_Id {
	return create_input_mapping(cast(s32)button, cast(u8)check_type);
}

create_input :: (button: Gamepad_Button, check_type: Gamepad_Button_Check_Type) -> Input_Mapping_Id {
	return create_input_mapping(cast(s32)button, cast(u8)check_type);
}

create_input :: (axis: Gamepad_Axis, check_type: Gamepad_Axis_Check_Type) -> Input_Mapping_Id {
	return create_input_mapping(cast(s32)axis, cast(u8)check_type);
}

create_input :: (axis: Mouse_Axis, check_type: Mouse_Axis_Check_Type) -> Input_Mapping_Id {
	return create_input_mapping(cast(s32)axis, cast(u8)check_type);
}

update_inputs :: () {
	mouse_pos := rl.GetMousePosition();
	mouse_xy.x = mouse_pos.x;
	mouse_xy.y = mouse_pos.y;

	// @todo: change this to reflect a real gamepad:
	GAMEPAD_ID : s32 : 0;

	// Update every input:
	for _input_mappings {
		using it;
		if type == {
			// Keyboard buttons:
			case .KEY_DOWN;
				value = rl.IsKeyDown(target);
			case .KEY_PRESS;
				value = rl.IsKeyPressed(target);
			case .KEY_RELEASE;
				value = rl.IsKeyReleased(target);

			// Mouse buttons:
			case .MOUSE_DOWN;
				value = rl.IsMouseButtonDown(target);
			case .MOUSE_PRESS;
				value = rl.IsMouseButtonPressed(target);
			case .MOUSE_RELEASE;
				value = rl.IsMouseButtonReleased(target);

			// Gamepad buttons:
			case .GAMEPAD_DOWN;
				value = rl.IsGamepadButtonDown(GAMEPAD_ID, target);
			case .GAMEPAD_PRESS;
				value = rl.IsGamepadButtonPressed(GAMEPAD_ID, target);
			case .GAMEPAD_RELEASE;
				value = rl.IsGamepadButtonReleased(GAMEPAD_ID, target);

			// Gamepad axis:
			case .GAMEPAD_AXIS_MIN;
				axis_movement := rl.GetGamepadAxisMovement(GAMEPAD_ID, target);
				value = axis_movement >= GAMEPAD_AXIS_MIN_THRESHOLD;
			case .GAMEPAD_AXIS_MIN_NEGATIVE;
				axis_movement := rl.GetGamepadAxisMovement(GAMEPAD_ID, target);
				value = axis_movement <= (-1 * GAMEPAD_AXIS_MIN_THRESHOLD);

			// Mouse axis:
			case .MOUSE_AXIS_MIN;
				axis_movement := rl.GetMouseWheelMoveV().y; // @constraint: Engine only supports vertical mouse scroll.
				value = axis_movement >= MOUSE_AXIS_MIN_THRESHOLD;
			case .MOUSE_AXIS_MIN_NEGATIVE;
				axis_movement := rl.GetMouseWheelMoveV().y;
				value = axis_movement <= (-1 * MOUSE_AXIS_MIN_THRESHOLD);

			// Unknown!
			case;
				crash("Invalid input type!");
		}
	}
}

GAMEPAD_AXIS_MIN_THRESHOLD :: 0.2;
MOUSE_AXIS_MIN_THRESHOLD :: 0.2;

check_input :: (input: Input_Mapping_Id) -> bool {
	ptr := static_pool_get(_input_mappings, input);
	return ptr.value;
}

get_mouse_position :: inline () -> Vec2 {
	return mouse_xy;
}

#scope_module
/*
## Inputs: internal

	Inputs are stored in the { Static_Pool } capacity of which may be configured in the { common/config.jai }.
	Mouse position is a special case, so we just store it in a { Vec2f } global.

	Here is also defined:
	- { create_input_mapping }: which is a helper function used to reduce repetition when creating mappings.

	Todo:
	- move the globals into a context/global struct.
*/

create_input_mapping :: inline (input: s32, check: u8) -> Input_Mapping_Id {
	ptr, id := static_pool_new(_input_mappings);
	ptr.target = input;
	ptr.type = cast(Check_Type)check;

	return id;
}

_input_mappings: *Static_Pool(Input_Mapping, MAX_INPUT_MAPPINGS);
mouse_xy: Vec2;


// We cast any specific input type to check type underneath, the reason we have this separation is to
// make sure user maps the correct type with the correct check type. So you can't have a mouse button
// be checked as if it's an axis.
Check_Type :: enum u8 {
	// Keyboard button:
	KEY_DOWN 		:: 0;
	KEY_PRESS;
	KEY_RELEASE;

	// Mouse button:
	MOUSE_DOWN;
	MOUSE_PRESS;
	MOUSE_RELEASE;

	// Gamepad button:
	GAMEPAD_DOWN;
	GAMEPAD_PRESS;
	GAMEPAD_RELEASE;

	// Gamepad axis:
	GAMEPAD_AXIS_MIN;
	GAMEPAD_AXIS_MIN_NEGATIVE;

	// Mouse axis:
	MOUSE_AXIS_MIN;
	MOUSE_AXIS_MIN_NEGATIVE;
}
