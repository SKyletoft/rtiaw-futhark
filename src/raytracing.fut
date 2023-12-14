import "../lib/github.com/diku-dk/cpprandom/random"

import "vector"
import "colour"
import "option"
import "interval"

type Ray       = { origin: Vec3, dir: Vec3 }
type Sphere    = { pos: Vec3, radius: f32 }
type HitRecord = { pos: Vec3, normal: Vec3, t: f32, front_face: bool }
type Hittable  = #sphere Sphere

module Rng    = minstd_rand
type RngState = Rng.rng

def to_colour ({x, y, z}: Vec3): Pixel =
  { r = x, g = y, b = z }
  |> sq_px

def at (ray: Ray) (t: f32): Vec3 =
  ray.origin `add` (ray.dir `mul` t)

def set_face_normal (ray: Ray) (outward_normal: Vec3) (hr: HitRecord): HitRecord =
  let front_face = (ray.dir `dot` outward_normal) < 0
  let normal =
    if front_face
    then outward_normal
    else neg outward_normal
  in { pos = hr.pos, normal, t = hr.t, front_face }

def hit_record (ray: Ray) (sphere: Sphere) (t: f32): HitRecord =
  let pos = ray `at` t
  let n   = (pos `sub` sphere.pos) `div` sphere.radius
  in { t, pos, normal = n, front_face = false} |> set_face_normal ray n

def ray_sphere_hit (ray: Ray) (sphere: Sphere) (t: Interval): Option HitRecord =
  let oc     = ray.origin `sub` sphere.pos
  let a      = ray.dir |> length_squared
  let half_b = oc `dot` ray.dir
  let c      = length_squared oc - (sphere.radius * sphere.radius)

  let disc      = half_b * half_b - a * c
  let disc_sqrt = f32.sqrt disc

  let root  = (-half_b - disc_sqrt) / a
  let root' = (-half_b + disc_sqrt) / a

  in if disc < 0 then #none
     else if !(t `surrounds` root)
     then if !(t `surrounds` root')
          then #none
          else #some (hit_record ray sphere root')
     else #some (hit_record ray sphere root)

def ray_intersection (t: Interval) (ray: Ray) (hittable: Hittable): Option HitRecord =
  match hittable
    case #sphere s -> ray_sphere_hit ray s t

def sky (ray: Ray): Pixel =
  let a = -(ray.dir.y) * 0.8
  let white = { x = 1, y = 1, z = 1 }
  let blue = { x = 0.5, y = 0.7, z = 1.0 }
  in ((blue `mul` (1 - a)) `add` (white `mul` a)) |> to_colour

let one: Vec3 = { x = 1, y = 1, z = 1 }

def foldl' [n] 'a 'b (f: Option a -> b -> Option a) (acc: Option a) (xs: [n]b): Option a =
  if n == 0
  then #none
  else foldl f acc xs

def ray_colour (scene: []Hittable) (ray: Ray): Pixel =
  let keep_closer l r =
    match (l, r)
    case (#some l', #some r') -> #some (if l'.t <= r'.t then l' else r')
    case (#some _, #none)     -> l
    case (#none, #some _)     -> r
    case (#none, #none)       -> #none
  in match foldl' (\acc h -> ray_intersection (interval 0.01 f32.inf) ray h |> keep_closer acc)
                  #none
                  scene
     case #some hit -> ((hit.normal `add` one) `div` 2) |> to_colour
     case #none -> sky ray

-- | 0..1 → -1..1
def rescale (x: f32): f32 = x * 2 - 1

def fire_ray fovy x y: Ray =
  let x   = fovy * rescale x
  let y   = -rescale y
  let dir = unit_vector { x, y, z = -1 }
  in { origin, dir }

def trace scene fovy x y: Pixel =
  fire_ray fovy x y |> ray_colour scene

def draw_pixel (samples: i64) (rng: RngState) (scene: []Hittable) (w: i64) (h: i64) (x: i64) (y: i64): Pixel =
  let fovy = f32.i64 w / f32.i64 h
  let x = f32.i64 x
  let y = f32.i64 y
  let w' = f32.i64 w
  let h' = f32.i64 h
  let s = f32.i64 samples

  let remap v = (f32.u32 v) / (f32.u32 Rng.max) - 0.5

  let combine {r = r1, g = g1, b = b1} {r = r2, g = g2, b = b2} =
    { r = r1 + r2, g = g1 + g2, b = b1 + b2 }

  let draw rng =
    let (rng', dx) = Rng.rand rng
    let (rng'', dy) = Rng.rand rng'
    let x = (x + remap dx) / w'
    let y = (y + remap dy) / h'
    let new_col = trace scene fovy x y
    in (rng'', new_col)

  in iota (samples - 1)
     |> foldl (\(rng, acc_col) _ ->
		 let (rng', new_col) = draw rng
		 in (rng', acc_col `combine` new_col))
	      (draw rng)
     |> (\(_, {r, g, b}) -> { r = r / s, g = g / s, b = b / s })
