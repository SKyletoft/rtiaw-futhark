import "vector"
import "colour"

type Ray = { origin: Vec3, dir: Vec3 }
type Sphere = { pos: Vec3, radius: f32 }

def at (ray: Ray) (t: f32): Vec3 =
  ray.origin `add` (ray.dir `mul` t)

def ray_sphere_intersection (ray: Ray) (sphere: Sphere): bool =
  let oc = ray.origin `sub` sphere.pos
  let a = ray.dir `dot` ray.dir
  let b = (oc `mul` 2) `dot` ray.dir
  let c = (oc `dot` oc) - sphere.radius * sphere.radius
  let disc = b*b - 4*a*c
  in disc >= 0

def circle_sdf x y = f32.sqrt <| x * x + y * y

def ray_colour (scene: []Sphere) (ray: Ray): Pixel =
  let a = 1 - 0.5 * ray.dir.y
  let white = { x = 1, y = 1, z = 1 }
  let blue = { x = 0.5, y = 0.7, z = 1.0 }
  in ((white `mul` (1 - a)) `add` (blue `mul` a)) |> to_colour

-- | 0..1 → -1..1
def rescale (x: f32): f32 = x * 2 - 1

def fire_ray x y: Ray =
  let x = -rescale x
  let y = rescale y
  let dir = unit_vector { x, y, z = -1 }
  in { origin, dir }
				   
def trace scene fovy x y: Pixel =
  let y = y * fovy
  in fire_ray x y |> ray_colour scene
