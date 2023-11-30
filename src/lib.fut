type Pixel = {r: u8, g: u8, b: u8}
type PixelF32 = {r: f32, g: f32, b: f32}

def black: Pixel = {r = 0, g = 0, b = 0}
def black_f32: PixelF32 = {r = 0, g = 0, b = 0}
def black_image (h: i64) (w: i64): [h][w]Pixel =
  black
  |> replicate w
  |> replicate h

def average_two_colours (l: Pixel) (r: Pixel): Pixel =
  let sq x = let x' = f32.u8 x in x' * x'
  let rms x y = ((sq x + sq y) / 2) |> f32.sqrt |> u8.f32
  in { r = rms l.r r.r
     , g = rms l.g r.g
     , b = rms l.b r.b
     }

def average_colours (ps: []Pixel): Pixel =
  let sq x = let x' = f32.u8 x in x' * x'
  let sq_px {r, g, b} =
    {r = sq r, b = sq b, g = sq g}
  let add_px {r = r1, g = g1, b = b1} {r = r2, g = g2, b = b2} =
    {r = r1 + r2, g = g1 + g2, b = b1 + b2}
  let sqrt_u8 x = x |> f32.sqrt |> u8.f32
  let sqrt_px {r, g, b} =
    { r = sqrt_u8 r
    , g = sqrt_u8 g
    , b = sqrt_u8 b
    }
  in ps
      |> map sq_px
      |> reduce_comm add_px black_f32
      |> sqrt_px

-- | Gradient function. 0 <= h, w, lim < 1
def transform_pixel (h: f32) (w: f32): Pixel = 
  let conv_colour a =
    a
    |> (* 255.9999)
    |> u8.f32
  in {
    r = conv_colour h,
    g = conv_colour w,
    b = i32.f32 ((h * w) * 256 * 256) % 255 |> u8.i32
  }

-- | Take a function to generate a colour from pixel coordinates and create a full image from it
def create_image (f: f32 -> f32 -> Pixel) (h: i64) (w: i64): [h][w]Pixel =
  let ratio x = (f32.i64 x) / (f32.i64 h)
  let iota_ratio x = iota x |> map ratio
  in iota_ratio w
     |> replicate h
     |> zip (iota_ratio h)
     |> map (\(i, js) -> map (f i) js)

-- | Generate an image from `transform_pixel`
def colour_image (h: i64) (w:i64): [h][w]Pixel =
  create_image transform_pixel h w

-- | Flatten a pixel to an array
def pixel_to_arr (pixel: Pixel) = [pixel.r, pixel.g, pixel.b]

-- | Flatten an entire image to a byte array
def flatten_pixels (pxs: [][]Pixel): []u8 =
  pxs
  |> flatten
  |> map pixel_to_arr
  |> flatten

entry calc (h: i64) (w: i64): [h * w * 3]u8 =
  colour_image h w
  |> flatten_pixels
