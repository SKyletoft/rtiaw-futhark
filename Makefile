run-debug: debug
	target/debug/rust-futhark-test > image.ppm

run-release: release
	target/release/rust-futhark-test > image.ppm

bench: release
	hyperfine "target/release/rust-futhark-test > /dev/null"

debug: lib/github.com/diku-dk/cpprandom/random.fut
	cargo build --locked --offline
	patchelf --replace-needed libOpenCL.so.1 $$LIBOPENCL_BIN/lib/libOpenCL.so.1 target/debug/rust-futhark-test
	patchelf --replace-needed libhiprtc.so.5 $$ROCMCLR/lib/libhiprtc.so.5 target/debug/rust-futhark-test
	patchelf --replace-needed libamdhip64.so.5 $$ROCMCLR/lib/libamdhip64.so.5 target/debug/rust-futhark-test

release: debug lib/github.com/diku-dk/cpprandom/random.fut
	cargo build --release --locked --offline
	patchelf --replace-needed libOpenCL.so.1 $$LIBOPENCL_BIN/lib/libOpenCL.so.1 target/release/rust-futhark-test
	patchelf --replace-needed libhiprtc.so.5 $$ROCMCLR/lib/libhiprtc.so.5 target/release/rust-futhark-test
	patchelf --replace-needed libamdhip64.so.5 $$ROCMCLR/lib/libamdhip64.so.5 target/release/rust-futhark-test

lib/github.com/diku-dk/cpprandom/random.fut:
	futhark pkg sync

clean:
	cargo clean
	-rm lib -rf

.PHONY: debug release clean
