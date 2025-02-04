
#module_parameters()(
	IS_DEBUG: 		  bool 	 = true,
	ROOT_PATH: 		  string = "",
	CRASH_ON_WARNING: bool 	 = false,
	CRASH_ON_ERROR:   bool 	 = true
);


/* ## Constants */

IS_DEBUG_BUILD :: IS_DEBUG;


/* ## Aliases */

f32 :: float32;
f64 :: float64;


/* ## Print utilities */

caller_location_relative :: inline (caller: Source_Code_Location) -> string {
	assert(
		caller.fully_pathed_filename.count > ROOT_PATH.count,
		"Root path cannot be longer than the caller path!"
	);

	if ROOT_PATH.count > 0 {
		assert(
			contains(caller.fully_pathed_filename, ROOT_PATH),
			"Source file path must contain the root path!"
		);
	}

	return slice(
		caller.fully_pathed_filename,
		ROOT_PATH.count,
		caller.fully_pathed_filename.count-ROOT_PATH.count
	);
}

maybe_add_location_to_format :: inline (fmt: string, caller := #caller_location, print_location: bool = true) -> string {
	format := fmt;
	if print_location {
		relative_location := caller_location_relative(caller);
		format = tprint("%\n* % (%)", fmt, relative_location, caller.line_number);
	}

	return format;
}

print_error :: (fmt: string, args: ..Any, caller := #caller_location, print_location := true) {
	format := maybe_add_location_to_format(fmt, caller, print_location);

	if CRASH_ON_ERROR {
		print_color("\n=== [CRASH ON ERROR] ===\n\n", color= Console_Color.RED);
	}

	print_color("[ERROR]\n* %\n", tprint(format, ..args), color= Console_Color.RED);

	if CRASH_ON_ERROR {
		print_color("\n=== [CRASH ON ERROR] ===\n", color= Console_Color.RED);
		exit(1);
	}
}

print_info :: (fmt: string, args: ..Any, caller := #caller_location, print_location := true) {
	format := maybe_add_location_to_format(fmt, caller, print_location);
	print_color("[INFO]\n* %\n", tprint(format, ..args), color= Console_Color.CYAN);
}

print_warning :: (fmt: string, args: ..Any, caller := #caller_location, print_location := true) {
	format := maybe_add_location_to_format(fmt, caller, print_location);

	if CRASH_ON_WARNING {
		print_color("\n=== [CRASH ON WARNING] ===\n\n", color= Console_Color.RED);
	}

	print_color("[WARNING]\n* %\n", tprint(format, ..args), color= Console_Color.YELLOW);

	if CRASH_ON_WARNING {
		print_color("\n=== [CRASH ON WARNING] ===\n", color= Console_Color.RED);
		exit(1);
	}
}

info_if :: inline (condition: bool, fmt: string, args: ..Any, caller := #caller_location, print_location := true) {
	if !condition {
		return;
	}

	print_info(fmt, ..args, caller, print_location);
}

warning_if :: inline (condition: bool, fmt: string, args: ..Any, caller := #caller_location, print_location := true) {
	// Early quit if condition is not satisfied!
	if !condition {
		return;
	}

	print_warning(fmt, ..args, caller, print_location);
}

error_if :: inline (condition: bool, fmt: string, args: ..Any, caller := #caller_location, print_location := true) {
	if !condition {
		return;
	}

	print_error(fmt, ..args, caller, print_location);
}


#scope_file
crash :: (fmt: string, args: .. Any, caller := #caller_location, print_location := true) {
	format := maybe_add_location_to_format(fmt, caller, print_location);
	print_color("=== [CRASH] ===\n\n* %\n\n=== [CRASH] ===\n", tprint(format, ..args), color= Console_Color.RED);
	exit(1);
}

#import "Basic";
#import "String";
#import "Print_Color";
