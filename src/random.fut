import "../lib/github.com/diku-dk/cpprandom/random"

import "vector"
import "tuple"
import "interval"

module Rng    = minstd_rand
type RngState = Rng.rng

def random_f32 (rng: RngState): (RngState, f32) =
  second (\x -> f32.u32 x / f32.u32 Rng.max) (Rng.rand rng)

def random_f32_in (rng: RngState) (inv: Interval): (RngState, f32) =
  second (\x -> (inv.max - inv.min) * x + inv.min) (random_f32 rng)

def random_vec3 (rng: RngState): (RngState, Vec3) =
  let (r1, x) = random_f32 rng
  let (r2, y) = random_f32 r1
  let (r3, z) = random_f32 r2
  in (r3, { x, y, z })

def random_vec3_in (rng: RngState) (inv: Interval): (RngState, Vec3) =
  let (r1, x) = random_f32_in rng inv
  let (r2, y) = random_f32_in r1 inv
  let (r3, z) = random_f32_in r2 inv
  in (r3, { x, y, z })
