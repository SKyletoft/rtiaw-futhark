import "vector"
import "raytracing"
import "colour"
import "random"

-- | Flatten a pixel to an array
def pixel_to_arr ({r, g, b}: Pixel): [3]u8 =
  let f x =
    x
    |> f32.sqrt
    |> (* 255.9999)
    |> u8.f32
  in [f r, f g, f b]

entry calc (w: i64) (h: i64): [h * w * 3]u8 =
  let circle  = { pos = { x =  0, y =      0, z = -1 }, radius = 0.5 }
  let circle2 = { pos = { x = -4, y =      2, z = -8 }, radius =   2 }
  let circle3 = { pos = { x =  0, y = -100.5, z = -1 }, radius = 100 }
  let scene = [ #sphere circle
	      , #sphere circle2
	      , #sphere circle3
	      ]
  let rng     = Rng.rng_from_seed [981, 345, 234, 897, 82734, 2346]
  let rngs    = Rng.split_rng (w * h) rng
  let samples = 4096

  let pixel_coords: [h * w](i64, i64) =
    let row =
      iota h
    let column =
      iota w
    in column
      |> replicate h
      |> zip row
      |> map (\(i, js) -> map (\j -> (j, i)) js)
      |> flatten

  let f (x: i64) (y: i64): Pixel =
    let idx = y + x * h
    in draw_pixel samples rngs[idx] scene w h x y

  in pixel_coords |> map (\(x, y) -> f x y |> pixel_to_arr) |> flatten
