// example.fut could also be something like lib/example.fut, but the output name
// is always relative to $OUT_DIR
fn main() {
	println!("cargo:rerun-if-changed=src/lib.fut");
	println!("cargo:rerun-if-changed=src/colour.fut");
	println!("cargo:rerun-if-changed=src/vector.fut");
	println!("cargo:rerun-if-changed=src/raytracing.fut");
	futhark_bindgen::build(futhark_bindgen::Backend::Multicore, "src/lib.fut", "fut.rs")
}
