
/*
# Build

    Build may be configured in the { build_config.jai } file:
    - { PROJECT_NAME }: dictates the executable name.
    - { PROJECT_BUILD_MODE }: dictates the optimization level and build speed, { DEBUG } will be faster to build
      but much less optimized and { RELEASE } will be much slower to build but much more optimized. When
      building in { DEBUG } mode, executable name will also include { _Debug }.
    - { PROJECT_BUILD_VERBOSE }: if set to { true }, build may output extra information to the command line,
      otherwise it will not output anything.

    Entry point of the program is: { src/main.jai } and { build_config.jai } is preloaded into it. Any project
    specific or non-standard modules placed in the { LOCAL_MODULE_IMPORT_DIRECTORY } will be discoverable
    by { #import }.
*/

#import "Basic";
#import "Compiler";
#import "File_Utilities";
#import "File";
#import "Bindings_Generator";

#load "config.jai";

#run {
    // No output during compile time:
    set_build_options_dc(.{
        do_output= false,
        write_added_strings= false,
    });

    workspace := compiler_create_workspace(PROJECT_NAME);
    if !workspace {
        print("[build] workspace creation for: % failed!\n", PROJECT_NAME);
        return;
    }

    // Print out build configuration if verbose:
    if PROJECT_BUILD_VERBOSE {
        sb: String_Builder;
        print_to_builder(*sb, "\n--\n");
        print_to_builder(*sb, "name: \t\t%\n", PROJECT_NAME);
        print_to_builder(*sb, "version: \t%\n", PROJECT_VERSION);
        print_to_builder(*sb, "build_mode: \t%\n", PROJECT_BUILD_MODE);
        print_to_builder(*sb, "--\n");

        print(builder_to_string(*sb));
    }

    // Generate Raylib module if necessary:
    if !file_exists(tprint("%/raylib_win64", LOCAL_MODULE_IMPORT_DIRECTORY)) {
        generate_raylib_module("raylib_win64", "../vendor/raylib-5.5_win64_msvc16");
    }

    // Select build mode:
    if PROJECT_BUILD_MODE == {
        case .DEBUG;   do_debug_build(workspace);
        case .RELEASE; do_release_build(workspace);
        case; {
            print("Unsupported build mode selected: %\n", PROJECT_BUILD_MODE);
        }
    }
}

/*
    Debug build uses a faster backend { X64 }, but resulting application is not optimized.
    When compiling in Debug the resulting executable name will be modified to include { "_Debug" }.
*/
do_debug_build :: (workspace: Workspace) {
    options := get_build_options(workspace);

    options.output_executable_name  = tprint("%_Debug", PROJECT_NAME);
    options.backend                 = .X64;
    options.stack_trace             = true;
    options.intermediate_path       = BUILD_OUTPUT_DIRECTORY;
    options.output_path             = BUILD_OUTPUT_DIRECTORY;
    options.output_type             = .EXECUTABLE;
    options.write_added_strings     = false;

    if !PROJECT_BUILD_VERBOSE {
        options.text_output_flags   = 0;
    }

    set_optimization(*options, .DEBUG);

    // Add specified local module directory to import path:
    new_import_path: [..]string;
    array_add(*new_import_path, ..options.import_path);
    array_add(*new_import_path, LOCAL_MODULE_IMPORT_DIRECTORY);
    options.import_path = new_import_path;

    set_build_options(options, workspace);

    // Entry point & config file are preloaded:
    add_build_file("../src/main.jai", workspace);
    add_build_file("config.jai", workspace);
}

/*
    Release build uses a slower backend { LLVM }, but resulting application is optimized.
*/
do_release_build :: (workspace: Workspace) {
    options := get_build_options(workspace);

    options.output_executable_name  = PROJECT_NAME;
    options.backend                 = .LLVM;
    options.stack_trace             = false;
    options.intermediate_path       = BUILD_OUTPUT_DIRECTORY;
    options.output_path             = BUILD_OUTPUT_DIRECTORY;
    options.output_type             = .EXECUTABLE;
    options.write_added_strings     = false;

    if !PROJECT_BUILD_VERBOSE {
        options.text_output_flags   = 0;
    }

    set_optimization(*options, .VERY_OPTIMIZED);

    // Add specified local module directory to import path:
    new_import_path: [..]string;
    array_add(*new_import_path, ..options.import_path);
    array_add(*new_import_path, LOCAL_MODULE_IMPORT_DIRECTORY);
    options.import_path = new_import_path;

    set_build_options(options, workspace);

    // Entry point & config file are preloaded:
    add_build_file("src/main.jai", workspace);
    add_build_file("config.jai", workspace);
}

/*
    Generate the raylib module, right now it works for windows only!
*/
generate_raylib_module :: (module_name: string, raylib_path: string) {
    using options: Generate_Bindings_Options;
    strip_flags                         = 0;
    generate_compile_time_struct_checks = false;
    alias_original_enum_names           = false;
    c_enum_emulation                    = false;
    generate_library_declarations       = false;

    // Add definitions for things that are missing in the { module.jai } header.
    header = #string MODULE_HEADER
        va_list :: *void;
    MODULE_HEADER

    // Link against system libraries we need in the { module.jai } footer (order matters).
    footer = #string MODULE_FOOTER
        user32  :: #library,system,link_always,no_dll "user32";
        gdi32   :: #library,system,link_always,no_dll "gdi32";
        shell32 :: #library,system,link_always,no_dll "shell32";
        winmm   :: #library,system,link_always,no_dll "winmm";
        raylib  :: #library,no_dll "lib/raylib";
    MODULE_FOOTER

    // Add { Raylib } files to the generator.
    raylib_lib_directory     := tprint("%/lib", raylib_path);
    raylib_include_directory := tprint("%/include", raylib_path);

    array_add(*libpaths, raylib_lib_directory);
    array_add(*libnames, "raylib");
    array_add(*include_paths, raylib_include_directory);
    array_add(*source_files, ..string.["raylib.h", "raymath.h", "rlgl.h"]);

    // Generate module directory.
    raylib_module_directory     := tprint("%/%", LOCAL_MODULE_IMPORT_DIRECTORY, module_name);
    raylib_module_lib_directory := tprint("%/lib", raylib_module_directory);
    raylib_module_file          := tprint("%/module.jai", raylib_module_directory);

    // Recursively create directories for the Raylib module:
    make_directory_if_it_does_not_exist(raylib_module_lib_directory, true);

    // Generate bindings and save them as module.jai.
    generate_bindings(options, raylib_module_file);

    for string.["raylib.lib"] {
        file_src  := tprint("%/%", raylib_lib_directory, it);
        file_dest := tprint("%/%", raylib_module_lib_directory, it);

        copy_file(file_src, file_dest);
    }
}
