type Interval  = { min: f32, max: f32 }

def interval (min: f32) (max: f32): Interval =
  { min, max }

def contains (i: Interval) (value: f32): bool =
  i.min <= value && value <= i.max

def surrounds (i: Interval) (value: f32): bool =
  i.min < value && value < i.max

def empty_interval = interval f32.inf (-f32.inf)
def full_interval = interval (-f32.inf) f32.inf
