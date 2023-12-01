type Pixel = {r: u8, g: u8, b: u8}
type PixelF32 = {r: f32, g: f32, b: f32}
type Colour = {h: f32, s: f32, v: f32}

def black: Pixel = {r = 0, g = 0, b = 0}
def black_f32: PixelF32 = {r = 0, g = 0, b = 0}
def black_image (h: i64) (w: i64): [h][w]Pixel =
  black
  |> replicate w
  |> replicate h

-- According to chatgpt
def hsv_to_rgb(colour: Colour): PixelF32 =
  let {h, s, v} = colour
  let c = v * s
  let hp = h / 60.0
  let x = c * (1.0 - f32.abs(hp % 2.0 - 1.0))
  let m = v - c
  let h = h
  let (r, g, b) =
    if h >= 0.0 && h < 60.0 then (c, x, 0.0)
    else if h >= 60.0 && h < 120.0 then (x, c, 0.0)
    else if h >= 120.0 && h < 180.0 then (0.0, c, x)
    else if h >= 180.0 && h < 240.0 then (0.0, x, c)
    else if h >= 240.0 && h < 300.0 then (x, 0.0, c)
    else (c, 0.0, x)
  in { r = r + m, g = g + m, b = b + m }

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
  let add_px l r =
    {r = r.r + l.r, g = r.g + l.g, b = r.b + l.b}
  let sqrt_u8 x = x |> f32.sqrt |> u8.f32
  let sqrt_px {r, g, b} =
    { r = sqrt_u8 r , g = sqrt_u8 g , b = sqrt_u8 b}
  in ps
     |> map sq_px
     |> reduce_comm add_px black_f32
     |> sqrt_px

-- | Convert a floating value in range 0..1 to a 0..255 byte value
def lin_to_byte (x: f32): u8 =
  x
  |> (* 255.9999)
  |> u8.f32

-- | Gradient function. 0 <= h, w, lim < 1
def transform_pixel (w: f32) (h: f32): Pixel = {
  r = lin_to_byte w,
  g = lin_to_byte h,
  b = 0
}

-- | Take a function to generate a colour from pixel coordinates and create a full image from it
def create_image (f: f32 -> f32 -> Pixel) (w: i64) (h: i64): [h][w]Pixel =
  let row =
    iota w
    |> map (\x -> x |> f32.i64 |> (/ (f32.i64 w)))
  let column =
    iota h
    |> map (\x -> x |> f32.i64 |> (/ (f32.i64 h)))
  in row
     |> replicate h
     |> zip column
     |> map (\(i, js) -> map (`f` i) js)

-- | Generate an image from `transform_pixel`
def colour_image (w: i64) (h: i64): [h][w]Pixel =
  create_image transform_pixel w h
