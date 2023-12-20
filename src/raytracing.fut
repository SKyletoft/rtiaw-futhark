import "vector"
import "colour"
import "option"
import "tuple"
import "interval"
import "random"

type Metal    = { albedo: Vec3, roughness: f32 }
type Diffuse  = { albedo: Vec3 }
type Glass    = { ior: f32 }
type Material
  = #metal Metal
  | #diffuse Diffuse
  | #glass Glass

type Ray       = { origin: Vec3, dir: Vec3 }
type Sphere    = { pos: Vec3, radius: f32, mat: Material }
type HitRecord = { pos: Vec3, normal: Vec3, t: f32, front_face: bool, mat: Material }
type Hittable  = #sphere Sphere

def scatter_diffuse (rng: RngState) (_: Ray) (hr: HitRecord) (mat: Diffuse): (RngState, Option (Ray, Vec3)) =
  let (rng', rng_offset) = random_unit_vec3 rng
  let dir_cand = rng_offset `add` hr.normal
  let dir = if near_zero dir_cand
	    then hr.normal
	    else dir_cand
  let ray' = { origin = hr.pos, dir }
  let col = mat.albedo
  in (rng', #some (ray', col))

def scatter_metal (rng: RngState) (ray: Ray) (hr: HitRecord) (mat: Metal): (RngState, Option (Ray, Vec3)) =
  let (rng', rng_offset) = random_unit_vec3 rng
  let reflected = reflect (unit_vector ray.dir) hr.normal
  let dir = reflected `add` (rng_offset `mul` mat.roughness)
  let ray' = { origin = hr.pos, dir }
  in if (dir `dot` hr.normal) > 0
     then (rng', #some (ray', mat.albedo))
     else (rng', #none)

def scatter_glass (rng: RngState) (ray: Ray) (hr: HitRecord) (mat: Glass): (RngState, Option (Ray, Vec3)) =
  let col = white'
  let refr_ratio =
    if hr.front_face
    then 1 / mat.ior
    else mat.ior
  let unit_dir = unit_vector ray.dir
  let refracted = refract unit_dir hr.normal refr_ratio
  let ray' = { origin = hr.pos, dir = refracted }
  in (rng, #some (ray', col))

def scatter (rng: RngState) (ray: Ray) (hr: HitRecord) (mat: Material): (RngState, Option (Ray, Vec3)) =
  match mat
  case #metal m   -> scatter_metal rng ray hr m
  case #diffuse m -> scatter_diffuse rng ray hr m
  case #glass m   -> scatter_glass rng ray hr m

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
  in { pos = hr.pos, normal, t = hr.t, front_face, mat = hr.mat }

def hit_record (ray: Ray) (sphere: Sphere) (t: f32): HitRecord =
  let pos = ray `at` t
  let n   = (pos `sub` sphere.pos) `div` sphere.radius
  in { t, pos, normal = n, front_face = false, mat = sphere.mat } |> set_face_normal ray n

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

def sky (ray: Ray): Vec3 =
  let a	    = (-(unit_vector ray.dir).y + 1.0) / 2.0
  let white = one
  let blue  = sky_blue
  in ((blue `mul` (1 - a)) `add` (white `mul` a))

def ray_colour (rng: RngState) (scene: []Hittable) (ray: Ray): (RngState, Pixel) =
  let keep_closer l r =
    match (l, r)
    case (#some l', #some r') -> #some (if l'.t <= r'.t then l' else r')
    case (#some _, #none)     -> l
    case (#none, #some _)     -> r
    case (#none, #none)       -> #none

  let ray_colour' rng_l ray l =
    match foldl (\acc h -> ray_intersection (interval 0.01 f32.inf) ray h |> keep_closer acc)
		 #none
		 scene
    case #some hit ->
      (match scatter rng_l ray hit hit.mat
      case (rng_l', #some (ray', col')) -> (rng_l', ray', true, col', l)
      case (rng_l', #none)              -> (rng_l', ray, false, black', l))
    case #none ->
      (rng, ray, false, sky ray, l)

  let (rng', _, _, colour, loops) =
    loop (rng, ray, continue, colour, loops) = (rng, ray, true, one, -1f32)
    while continue && loops < 10
    do let (rng, ray, continue, colour', loops) = ray_colour' rng ray (loops + 1f32)
       let colour'' = colour `mul_elem` colour'
       in (rng, ray, continue, colour'', loops)

  in (rng', to_colour colour)

-- | 0..1 → -1..1
def rescale (x: f32): f32 = x * 2 - 1

def fire_ray fovy x y: Ray =
  let x   = fovy * rescale x
  let y   = -rescale y
  let dir = unit_vector { x, y, z = -1 }
  in { origin, dir }

def trace (rng: RngState) (scene: []Hittable) (fovy: f32) (x: f32) (y: f32): (RngState, Pixel) =
  fire_ray fovy x y |> ray_colour rng scene

def draw_pixel (samples: i64) (rng: RngState) (scene: []Hittable) (w: i64) (h: i64) (x: i64) (y: i64): Pixel =
  let fovy = f32.i64 w / f32.i64 h
  let x    = f32.i64 x
  let y    = f32.i64 y
  let w'   = f32.i64 w
  let h'   = f32.i64 h
  let s    = f32.i64 samples

  let remap v = (f32.u32 v) / (f32.u32 Rng.max) - 0.5

  let combine {r = r1, g = g1, b = b1} {r = r2, g = g2, b = b2} =
    { r = r1 + r2, g = g1 + g2, b = b1 + b2 }

  let draw rng =
    let (rng, dx)      = Rng.rand rng
    let (rng, dy)      = Rng.rand rng
    let x              = (x + remap dx) / w'
    let y              = (y + remap dy) / h'
    let (rng, new_col) = trace rng scene fovy x y
    in (rng, new_col)

  let (_, {r,g,b}) =
    loop (rng, acc_col) = draw rng
    for x < (samples - 1)
    do let (rng', new_col) = draw rng
       in (rng', acc_col `combine` new_col)

  in { r = r / s, g = g / s, b = b / s }
