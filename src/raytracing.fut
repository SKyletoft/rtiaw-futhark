import "vector"
import "colour"

type Ray = { origin: Vec3, dir: Vec3 }
type Sphere = { pos: Vec3, radius: f32 }

def at (ray: Ray) (t: f32): Vec3 =
  ray.origin `add` (ray.dir `mul` t)

def ray_sphere_intersection (ray: Ray) (sphere: Sphere): f32 =
  let oc = ray.origin `sub` sphere.pos
  let a = ray.dir `dot` ray.dir
  let b = (oc `mul` 2) `dot` ray.dir
  let c = (oc `dot` oc) - sphere.radius * sphere.radius
  let disc = b*b - 4*a*c
  in if disc < 0
     then -1
     else (-b - (f32.sqrt disc)) / (2*a)

def circle_sdf x y = x * x + y * y |> f32.sqrt

def sky (ray: Ray): Pixel =
  let a = -(ray.dir.y) * 0.8
  let white = { x = 1, y = 1, z = 1 }
  let blue = { x = 0.5, y = 0.7, z = 1.0 }
  in ((blue `mul` (1 - a)) `add` (white `mul` a)) |> to_colour
  
let one: Vec3 = {x = 1, y = 1, z = 1}

def ray_colour (scene: []Sphere) (ray: Ray): Pixel =
  let sphere = scene[0]
  let t = (ray_sphere_intersection ray) sphere
  in if t > 0
     then let normal = ((ray `at` t) `sub` sphere.pos) |> unit_vector
          in to_colour <| ((normal `add` one) `div` 2)
     else sky ray

-- | 0..1 → -1..1
def rescale (x: f32): f32 = x * 2 - 1

def fire_ray fovy x y: Ray =
  let x = fovy * (-rescale x)
  let y = rescale y
  let dir = unit_vector { x, y, z = -1 }
  in { origin, dir }
				   
def trace scene fovy x y: Pixel =
  fire_ray fovy x y |> ray_colour scene
