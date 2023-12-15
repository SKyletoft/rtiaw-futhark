def fst 'a 'b ((x, _): (a, b)): a = x
def snd 'a 'b ((_, x): (a, b)): b = x

def first  'a 'b 'c (f: a -> c) ((x, y): (a, b)): (c, b) = (f x, y)
def second 'a 'b 'c (f: b -> c) ((x, y): (a, b)): (a, c) = (x, f y)
