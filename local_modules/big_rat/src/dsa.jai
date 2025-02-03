/*
# big_rat: dsa

	Simple, general purpose data structures.
*/

/*
# Static_Pool

	This is an array that is pre-allocated and is counted from { 0 } to { capacity-1 } (inclusive). Difference between this and { Pool } is that a { Pool } is expected to be re-used during the lifetime of this application and { Static_Pool } is not!

	In general, this is another one of the simple data/memory management types. Allows us to create arrays of dynamic size without having to use { NewArray }.

	## { static_pool_new }

		Get an instance from the pool at the current index.

	## { static_pool_new_view }

		Get { count } instances as an array view, from the current index.

	## { static_pool_clear }

		Marks the pool as empty.
*/
Static_Pool :: struct($T: Type, $N: s16) {
	index: s16 = 0;
	data:  [N]T;
}


static_pool_new :: (using instance: *Static_Pool($T, $N)) -> *T, s16 {
	assert(index < N, "Static_Pool is full!");

	element := *data[index];
	element_index := index;

	index += 1;

	return element, element_index;
}


static_pool_new_view :: (using instance: *Static_Pool($T, $N), count: s16) -> []T, s16 {
	// We count { N + 1 } here, because we are adding { count } before creating the element.
	assert((index + count) < N + 1, "Static_Pool is full!");

	view := array_view(data, index, count);
	view_index := index;

	index += count;
	return view, index;
}


static_pool_clear :: (using instance: *Static_Pool($T, $N)) {
	index = 0;
}

for_expansion :: (instance: *Static_Pool($T, $N), body: Code, flags: For_Flags) #expand {
	max := ifx instance.index == N then N-1 else instance.index;
	for index: 0..max-1 {
		`it_index := index;
		`it := *instance.data[index];

		#insert body;
	}
}


static_pool_get :: (instance: *Static_Pool($T, $N), index: s16) -> *T {
	assert(index >= 0 && index < N, "Invalid index given!");
	return *instance.data[index];
}

static_pool_full :: (instance: *Static_Pool($T, $N)) -> bool {
	return instance.index == instance.N-1;
}

/*
## Static_Pool: internals
*/
#scope_file
#if BIG_RAT_TEST_DSA #run {
	pool: Static_Pool(int, 128);

	// Creating new items 1 by 1:
	for 0..27 {
		item, index := static_pool_new(*pool);
		item.* = it * 2 + 1;
	}

	// Creating new items in batch:
	for 0..9 {
		items, index := static_pool_new_view(*pool, 10);
		x := it;
		for items {
			items[it_index] = x + it_index * 7;
		}
	}

 	// Clearing the items:
	assert(pool.index == 128);
	static_pool_clear(*pool);
	assert(pool.index == 0);

	// Populating the pool again:
	for 0..99 {
		item, index := static_pool_new(*pool);
	}

	iterations := 0;
	for pool {
		iterations += 1;
	}

	assert(iterations==100);

	// Done
	log("big_rat/Static_Pool: test passed!\n");
}
