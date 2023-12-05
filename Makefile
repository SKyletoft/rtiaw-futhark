debug:
	cargo build
	patchelf --replace-needed libOpenCL.so.1 $$LIBOPENCL_BIN/lib/libOpenCL.so.1 target/debug/rust-futhark-test
	patchelf --replace-needed libhiprtc.so.5 $$ROCMCLR/lib/libhiprtc.so.5 target/debug/rust-futhark-test
	patchelf --replace-needed libamdhip64.so.5 $$ROCMCLR/lib/libamdhip64.so.5 target/debug/rust-futhark-test
	target/debug/rust-futhark-test > image.ppm

release:
	cargo build -r
	patchelf --replace-needed libOpenCL.so.1 $$LIBOPENCL_BIN/lib/libOpenCL.so.1 target/release/rust-futhark-test
	patchelf --replace-needed libhiprtc.so.5 $$ROCMCLR/lib/libhiprtc.so.5 target/release/rust-futhark-test
	patchelf --replace-needed libamdhip64.so.5 $$ROCMCLR/lib/libamdhip64.so.5 target/release/rust-futhark-test
	target/release/rust-futhark-test > image.ppm

clean:
	cargo clean

.PHONY: debug release clean
