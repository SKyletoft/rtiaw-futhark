type Vec3 = {x: f32, y: f32, z: f32}

def add (lhs: Vec3) (rhs: Vec3): Vec3 = {
    x = lhs.x + rhs.x,
    y = lhs.y + rhs.y,
    z = lhs.z + rhs.z
  }

def sub (lhs: Vec3) (rhs: Vec3): Vec3 = {
    x = lhs.x - rhs.x,
    y = lhs.y - rhs.y,
    z = lhs.z - rhs.z
  }

def mul (lhs: Vec3) (rhs: f32): Vec3 = {
    x = lhs.x * rhs,
    y = lhs.y * rhs,
    z = lhs.z * rhs
  }

def mul_elem (lhs: Vec3) (rhs: Vec3): Vec3 = {
    x = lhs.x * rhs.x,
    y = lhs.y * rhs.y,
    z = lhs.z * rhs.z
  }

def div (lhs: Vec3) (rhs: f32): Vec3 = {
    x = lhs.x / rhs,
    y = lhs.y / rhs,
    z = lhs.z / rhs
  }

def neg (v: Vec3): Vec3 = {
    x = -v.x,
    y = -v.y,
    z = -v.z
  }

def length_squared (v: Vec3): f32 =
  v.x * v.x + v.y * v.y + v.z * v.z

def length (v: Vec3): f32 =
  v |> length_squared |> f32.sqrt

def dot (v: Vec3) (u: Vec3): f32 =
  v.x * u.x + v.y * u.y + v.z * u.z

def cross (u: Vec3) (v: Vec3): Vec3 = {
    x = u.y * v.z - u.z * v.y,
    y = u.z * v.x - u.x * v.z,
    z = u.x * v.y - u.y * v.x
  }

def near_zero (v: Vec3): bool =
  let epsilon = 1e-8
  in (f32.abs v.x) < epsilon
     && (f32.abs v.y) < epsilon
     && (f32.abs v.z) < epsilon

def unit_vector (v: Vec3): Vec3 =
  v `div` length v

def reflect (v: Vec3) (normal: Vec3): Vec3 =
  v `sub` (normal `mul` ((v `dot` normal) * 2))

def refract (uv: Vec3) (n: Vec3) (ior: f32): Vec3 =
  let cos_theta = f32.min ((neg uv) `dot` n) 1.0
  let r_out_perpendicular = (uv `add` (n `mul` cos_theta)) `mul` ior
  let r_out_parallel = n `mul` -((1.0 - length_squared r_out_perpendicular) |> f32.abs |> f32.sqrt)
  in r_out_perpendicular `add` r_out_parallel

def origin: Vec3 = { x = 0, y = 0, z = 0 }

def one: Vec3      = { x = 1, y = 1, z = 1 }
def sky_blue: Vec3 = { x = 0.5, y = 0.7, z = 1.0 }
