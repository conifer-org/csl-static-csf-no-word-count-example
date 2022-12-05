use std::any::Any;
use std::ops::Deref;
use std::slice;
use std::str;
use serde::{Serialize, Deserialize};

use postcard::{from_bytes, to_allocvec};

/// Let's enjoy doing some decorations
/// THis is App-dev defined
#[csl::atom(name = "decorate_string_atom1")]
#[csl::boot_electron]
fn enjoy_decorating() {
	let input = String::from("Tarun likes doing this");
	let decorated = decorate_string_sender_stub(input);
	csl::print(decorated.as_str());
}

#[csl::atom(name = "decorate_string_atom1")]
fn decorate_string_sender_stub(input: String) -> String {
	let handle1 = csl::spawn(
		"decorate_string_receiver_stub",
		Some((input,))
	);

	let output = csl::join::<String>(handle1).unwrap();

	return output;
}


/// Stub function to invoke `decorate_string`
/// It's invoked from the outside with arguments and returns a return value
/// > This function is autogenerated by CSL
#[no_mangle]
#[csl::atom(name = "decorate_string_atom2")]
pub extern "C" fn decorate_string_receiver_stub(index: i32, len: i32) -> i32 {
	let args = csl::get_args::<(String,)>(index as u32, len as usize);

	let output = decorate_string(args.0);

	let ret_val_vec = to_allocvec(&output).unwrap();
	let ret_index = csl::put_ret_val(ret_val_vec);

	ret_index as i32
}

/// A developer-defined function that takes a String and "decorates" it
#[csl::atom(name = "decorate_string_atom2")]
fn decorate_string(input: String) -> String {
	format!("( ͡° ͜ʖ ͡°)_/¯ {input} ( ͡° ͜ʖ ͡°)_/¯")
}