type Pixel = {r: u8, g: u8, b: u8}

def black: Pixel = {r = 0, g = 0, b = 0}
def black_image (h: i64) (w: i64): [h][w]Pixel =
  black
  |> replicate w
  |> replicate h

def transform_pixel (lim: i64) (h: i64) (w: i64): Pixel = 
  let conv_colour a =
    a
    |> f32.i64
    |> (/ f32.i64 lim)
    |> (* 255.9999)
    |> u8.f32
  in {
    r = conv_colour h,
    g = conv_colour w,
    b = conv_colour ((h * w) % lim)
  }

def create_image (f: i64 -> i64 -> Pixel) (x: i64) (y: i64): [x][y]Pixel =
  let line = iota y
  let lines = replicate x line
  let inner ((i, js): (i64, []i64)): []Pixel = map (f i) js
  in zip (iota x) lines |> map inner

def colour_image (h: i64) (w:i64): [h][w]Pixel =
  create_image (transform_pixel h) h w

def pixel_to_arr (pixel: Pixel) = [pixel.r, pixel.g, pixel.b]

def flatten_pixels (pxs: [][]Pixel): []u8 =
  pxs
  |> flatten
  |> map pixel_to_arr
  |> flatten

entry calc (h: i64) (w: i64) =
  colour_image h w
  |> flatten_pixels
