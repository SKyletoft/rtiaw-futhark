import "vector"
import "raytracing"
import "colour"
import "random"
import "scenes"

-- | Flatten a pixel to an array
def pixel_to_arr ({r, g, b}: Pixel): [3]f32 = [r, g, b]

entry calc (w: i64) (h: i64): [h * w * 3]f32 =
  let rng     = Rng.rng_from_seed [981, 345, 234, 897, 82734, 2346]
  let rngs    = Rng.split_rng (w * h) rng
  let samples = 128

  let (camera, scene) = copy four_spheres

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

  let trace_pixel ((x, y): (i64, i64)): [3]f32 =
    let idx = y + x * h
    in draw_pixel samples rngs[idx] scene camera w h x y
       |> pixel_to_arr

  in pixel_coords |> map trace_pixel |> flatten
