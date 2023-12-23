import "raytracing"
import "colour"

def four_spheres: (Camera, []Hittable) =
  let camera  = gen_camera { x = 3.5, y = 0, z = 1 } { x = 0, y = 0, z = -1 } 0.05
  let circle  = { pos = { x =   0, y =      0, z = -1 }, radius =   0.5, mat = #diffuse { albedo = red'   } }
  let circle2 = { pos = { x = -20, y =      2, z = -8 }, radius =     2, mat = #metal   { albedo = white', roughness = 0.3 } }
  let circle3 = { pos = { x =   0, y = -100.5, z = -1 }, radius =   100, mat = #diffuse { albedo = green' } }
  let circle4 = { pos = { x =   1, y =      0, z = -1 }, radius =   0.5, mat = #metal   { albedo = { x = 0.8, y = 0.6, z = 0.2 }, roughness = 1.0 } }
  let circle5 = { pos = { x =  -1, y =      0, z = -1 }, radius =   0.5, mat = #glass   { ior = 1.5 } }
  let circle6 = { pos = { x =  -1, y =      0, z = -1 }, radius = -0.45, mat = #glass   { ior = 1.5 } }
  let scene = [ #sphere circle
              , #sphere circle2
              , #sphere circle3
              , #sphere circle4
              , #sphere circle5
              , #sphere circle6
              ]
  in (camera, scene)
