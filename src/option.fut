type Option 'a = #some a | #none

def fmap 'a 'b (f: a -> b) (x: Option a): Option b =
  match x
  case #some x' -> #some (f x')
  case #none	-> #none

def return 'a (x: a): Option a = #some x

def (>>=) 'a 'b (x: Option a) (f: a -> Option b): Option b =
  match x
  case #some x' -> f x'
  case #none -> #none
