import "vector"
import "colour"

type Ray = { origin: Vec3, dir: Vec3 }
type Sphere = { pos: Vec3, radius: f32 }
type HitRecord = { pos: Vec3, normal: Vec3, t: f32 }

type Hittable = #sphere Sphere

type Option 'a = #some a | #none

def at (ray: Ray) (t: f32): Vec3 =
  ray.origin `add` (ray.dir `mul` t)

def ray_sphere_hit (ray: Ray) (sphere: Sphere) (t_max: f32) (t_min: f32): Option HitRecord =
  let oc = ray.origin `sub` sphere.pos
  let a = ray.dir |> length_squared
  let half_b = oc `dot` ray.dir
  let c = length_squared oc - (sphere.radius * sphere.radius)
  let disc = half_b * half_b - a * c
  in if disc < 0
    then #none
    else
  let disc_sqrt = f32.sqrt disc
  let root = (-half_b - disc_sqrt) / a
  in if root <= t_min || t_max <= root then
    let root' = (-half_b + disc_sqrt) / a
    in if root <= t_min || t_max <= root
      then #none
    else
      let t = root'
      let p = ray `at` t
      let n = (p `sub` sphere.pos) `div` sphere.radius
      in #some { t = t, pos = p, normal = n }
  else
    let t = root
    let p = ray `at` t
    let n = (p `sub` sphere.pos) `div` sphere.radius
    in #some { t = t, pos = p, normal = n }

def ray_intersection (ray: Ray) (hittable: Hittable) (t_max: f32) (t_min: f32): Option HitRecord =
  match hittable
    case #sphere s -> ray_sphere_hit ray s t_max t_min

def circle_sdf x y = x * x + y * y |> f32.sqrt

def sky (ray: Ray): Pixel =
  let a = -(ray.dir.y) * 0.8
  let white = { x = 1, y = 1, z = 1 }
  let blue = { x = 0.5, y = 0.7, z = 1.0 }
  in ((blue `mul` (1 - a)) `add` (white `mul` a)) |> to_colour
  
let one: Vec3 = {x = 1, y = 1, z = 1}

def ray_colour (scene: []Sphere) (ray: Ray): Pixel =
  let sphere = scene[0]
  -- in match (ray_sphere_hit ray) sphere
      -- case #some hr ->
       -- let normal = ((ray `at` t) `sub` sphere.pos) |> unit_vector
          -- in ((normal `add` one) `div` 2) |> to_colour
          -- case #nothing -> sky ray
  in sky ray

-- | 0..1 → -1..1
def rescale (x: f32): f32 = x * 2 - 1

def fire_ray fovy x y: Ray =
  let x = fovy * (-rescale x)
  let y = rescale y
  let dir = unit_vector { x, y, z = -1 }
  in { origin, dir }
				   
def trace scene fovy x y: Pixel =
  fire_ray fovy x y |> ray_colour scene
