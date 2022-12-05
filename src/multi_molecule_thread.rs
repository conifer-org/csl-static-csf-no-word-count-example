
/// Stub function to run some test code for Multi-MoleculeThreads TEMPORARY
#[no_mangle]
pub extern "C" fn multi_moleculethreads_test_no_args_stub(_: i32,_: i32) -> i32 {
	let handle1 = csl::spawn::<()>("print_numbers_loop_no_args_stub", None);
	csl::print(&format!("Started Thread 1: {}", handle1));
	let handle2 = csl::spawn::<()>("print_numbers_loop_no_args_stub", None);
	csl::print(&format!("Started Thread 2: {}", handle2));
	return 0;
}

static THE_NUM: AtomicU32 = AtomicU32::new(0);
static LOOP_ID: AtomicU32 = AtomicU32::new(0);

/// Stub function to run some test code for Print numbers in a loop TEMPORARY
#[no_mangle]
pub extern "C" fn print_numbers_loop_no_args_stub(_: i32, _: i32) -> i32 {
	let loop_id = LOOP_ID.fetch_add(1, Ordering::SeqCst);
	for _ in 0..50 {
		csl::print(&format!("Loop ID {} num: {}", loop_id, THE_NUM.fetch_add(1, Ordering::SeqCst)));
	}
	return 0;
}
