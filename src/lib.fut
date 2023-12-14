import "vector"
import "raytracing"
import "colour"

-- | Flatten a pixel to an array
def pixel_to_arr (pixel: Pixel) = [pixel.r, pixel.g, pixel.b]

-- | Flatten an entire image to a byte array
def flatten_pixels [w] [h] (pxs: [w][h]Pixel): [w * h * 3]u8 =
  pxs
  |> flatten
  |> map pixel_to_arr
  |> flatten

def aspect_ratio w h = f32.i64 w / f32.i64 h

entry calc (w: i64) (h: i64): [h * w * 3]u8 =
  let circle  = { pos = { x =  0, y =       0, z = -1 }, radius =  0.5 }
  let circle2 = { pos = { x = -4, y =       2, z = -8 }, radius =    2 }
  let circle3 = { pos = { x =  0, y = -1000.5, z = -1 }, radius = 1000 }
  let scene = [ #sphere circle
	      , #sphere circle2
	      , #sphere circle3
	      ]
  in create_image (trace scene (aspect_ratio w h)) w h
     |> flatten_pixels
