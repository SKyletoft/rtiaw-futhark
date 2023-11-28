pub mod fut;

fn main() {
	let res = with_futhark().unwrap();
	println!("{:#?}", res);
}

fn with_futhark() -> Result<Vec<f64>, fut::Error> {
	let ctx = fut::Context::new()?;

	let data = (1..=10).map(|i| i as f64).collect::<Vec<_>>();
	let arr = fut::ArrayF64D1::new(&ctx, [data.len() as _], &data)?;

	let res = ctx.hi(&arr)?;

	res.get()
}
