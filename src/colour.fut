type Pixel = {r: f32, g: f32, b: f32}
type Colour = {h: f32, s: f32, v: f32}

def red: Pixel = {r = 1, g = 0, b = 0}
def black: Pixel = {r = 0, g = 0, b = 0}

-- According to chatgpt
def hsv_to_rgb(colour: Colour): Pixel =
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
  let sq x = x * x
  let rms x y = ((sq x + sq y) / 2)
  in { r = rms l.r r.r
     , g = rms l.g r.g
     , b = rms l.b r.b
     }

def slet {r, g, b} =
  let sq x = let x' = f32.u8 x in x' * x'
  in { r = sq r, b = sq b, g = sq g }

def sq_px ({r, g, b}: Pixel): Pixel =
  { r = r * r, g = g * g, b = b * b }

def add_px (l: Pixel) (r: Pixel) =
  { r = r.r + l.r, g = r.g + l.g, b = r.b + l.b }

def sqrt_px ({r, g, b}: Pixel): Pixel =
  { r = f32.sqrt r , g = f32.sqrt g , b = f32.sqrt b }

def average_colours (ps: []Pixel): Pixel =
  ps
  |> map sq_px
  |> reduce_comm add_px black
  |> sqrt_px

-- | Take a function to generate a colour from pixel coordinates and create a full image from it
def create_image (f: f32 -> f32 -> Pixel) (w: i64) (h: i64): [h][w]Pixel =
  let row =
    iota w
    |> reverse
    |> map (\x -> x |> f32.i64 |> (/ (f32.i64 w - 1)))
  let column =
    iota h
    |> reverse
    |> map (\x -> x |> f32.i64 |> (/ (f32.i64 h - 1)))
  in row
     |> replicate h
     |> zip column
     |> map (\(i, js) -> map (`f` i) js)
