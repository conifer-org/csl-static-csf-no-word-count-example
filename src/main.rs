fn main() {
	let mut user_input = String::new();
	let stdin = std::io::stdin(); // We get `Stdin` here.
	stdin.read_line(&mut user_input).unwrap();

	println!("input {} ", user_input);
	csl::print(&user_input);
}
