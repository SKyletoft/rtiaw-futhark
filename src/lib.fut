import "vector"
import "raytracing"
import "colour"
import "random"

-- | Flatten a pixel to an array
def pixel_to_arr ({r, g, b}: Pixel): [3]f32 = [r, g, b]

entry calc_with_scene (scene: []Hittable) (w: i64) (h: i64): [h * w * 3]f32 =
  iota (h * w * 3) |> map f32.i64

entry calc (w: i64) (h: i64): [h * w * 3]f32 =
  let circle  = { pos = { x =  0, y =      0, z = -1 }, radius =   0.5, mat = #diffuse { albedo = red'   } }
  let circle2 = { pos = { x = -4, y =      2, z = -8 }, radius =     2, mat = #metal   { albedo = white', roughness = 0.3 } }
  let circle3 = { pos = { x =  0, y = -100.5, z = -1 }, radius =   100, mat = #diffuse { albedo = green' } }
  let circle4 = { pos = { x =  1, y =      0, z = -1 }, radius =   0.5, mat = #metal   { albedo = { x = 0.8, y = 0.6, z = 0.2 }, roughness = 1.0 } }
  let circle5 = { pos = { x = -1, y =      0, z = -1 }, radius =   0.5, mat = #glass   { ior = 1.5 } }
  let circle6 = { pos = { x = -1, y =      0, z = -1 }, radius = -0.45, mat = #glass   { ior = 1.5 } }
  let scene = [ #sphere circle
              , #sphere circle2
              , #sphere circle3
              , #sphere circle4
              , #sphere circle5
              , #sphere circle6
              ]
  let rng     = Rng.rng_from_seed [981, 345, 234, 897, 82734, 2346]
  let rngs    = Rng.split_rng (w * h) rng
  let samples = 128

  let camera = gen_camera { x = -0.5, y = 0, z = 2 } { x = 0, y = 0, z = -1 }

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
