// example.fut could also be something like lib/example.fut, but the output name
// is always relative to $OUT_DIR
fn main() {
	futhark_bindgen::build(futhark_bindgen::Backend::C, "src/lib.fut", "fut.rs")
}
