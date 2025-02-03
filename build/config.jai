/*
## Project Configuration

    This file is automatically loaded into the entry point as well.
*/

PROJECT_NAME           :: "Koschei";
PROJECT_VERSION        :: "0.1.0";
PROJECT_BUILD_MODE     :: Project_Build_Mode.DEBUG;
PROJECT_BUILD_VERBOSE  :: false;

BUILD_OUTPUT_DIRECTORY        :: "../bin/";
LOCAL_MODULE_IMPORT_DIRECTORY :: "../local_modules";

/*
    Helper type for build mode selection.
*/
Project_Build_Mode : enum u8 {
    DEBUG   :: 0;
    RELEASE :: 1;
}
