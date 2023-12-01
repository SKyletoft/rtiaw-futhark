import "vector"
import "raytracing"
import "colour"

-- | Flatten a pixel to an array
def pixel_to_arr (pixel: Pixel) = [pixel.r, pixel.g, pixel.b]

-- | Flatten an entire image to a byte array
def flatten_pixels (pxs: [][]Pixel): []u8 =
  pxs
  |> flatten
  |> map pixel_to_arr
  |> flatten

def aspect_ratio w h = f32.i64 w / f32.i64 h

entry calc (w: i64) (h: i64): [h * w * 3]u8 =
  -- colour_image w h
 create_image (trace [] (aspect_ratio w h)) w h
  |> flatten_pixels
