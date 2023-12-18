fn main() {
	println!("cargo:rerun-if-changed=src/colour.fut");
	println!("cargo:rerun-if-changed=src/interval.fut");
	println!("cargo:rerun-if-changed=src/lib.fut");
	println!("cargo:rerun-if-changed=src/option.fut");
	println!("cargo:rerun-if-changed=src/random.fut");
	println!("cargo:rerun-if-changed=src/raytracing.fut");
	println!("cargo:rerun-if-changed=src/tuple.fut");
	println!("cargo:rerun-if-changed=src/vector.fut");

	#[cfg(debug_assertions)]
	futhark_bindgen::build(futhark_bindgen::Backend::Multicore, "src/lib.fut", "fut.rs");
	#[cfg(not(debug_assertions))]
	futhark_bindgen::build(futhark_bindgen::Backend::HIP, "src/lib.fut", "fut.rs");
}
