import "colour"

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

def div (lhs: Vec3) (rhs: f32): Vec3 = {
    x = lhs.x / rhs,
    y = lhs.y / rhs,
    z = lhs.z / rhs
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

def unit_vector (v: Vec3): Vec3 =
  v `div` length v

def origin: Vec3 = { x = 0, y = 0, z = 0 }

def to_colour (v: Vec3): Pixel = {
    r = lin_to_byte v.x,
    g = lin_to_byte v.y,
    b = lin_to_byte v.z
  }
