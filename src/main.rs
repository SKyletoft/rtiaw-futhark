use std::fmt;

pub mod fut;

const RES: usize = 3;
const HEIGHT: usize = 1440 / RES;
const WIDTH: usize = 2560 / RES;

#[repr(C)]
#[derive(Copy, Clone, Debug, PartialEq)]
struct Colour {
	red: u8,
	green: u8,
	blue: u8,
}

impl fmt::Display for Colour {
	fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
		let Colour { red, green, blue } = *self;
		write!(f, "{red} {green} {blue}")
	}
}

fn main() {
	let res = with_futhark().unwrap();
	assert_eq!(res.len(), HEIGHT * WIDTH);
	println!("P3\n{WIDTH} {HEIGHT}\n255");
	for line in res.into_iter() {
		println!("{line}");
	}
}

fn with_futhark() -> Result<Vec<Colour>, fut::Error> {
	let ctx = fut::Context::new()?;

	let height = HEIGHT as _;
	let width = WIDTH as _;

	let f = |x: f32| (x.sqrt() * 255.9999) as u8;

	let res = ctx
		.calc(width, height)?
		.get()?
		.chunks_exact(3)
		.map(|arr| Colour {
			red: f(arr[0]),
			green: f(arr[1]),
			blue: f(arr[2]),
		})
		.collect();

	Ok(res)
}
