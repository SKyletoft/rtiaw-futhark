fn main() {
	println!("cargo:rerun-if-changed=src/lib.fut");
	println!("cargo:rerun-if-changed=src/colour.fut");
	println!("cargo:rerun-if-changed=src/vector.fut");
	println!("cargo:rerun-if-changed=src/raytracing.fut");
	futhark_bindgen::build(futhark_bindgen::Backend::OpenCL, "src/lib.fut", "fut.rs");
}
