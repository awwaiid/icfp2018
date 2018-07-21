
open Printf

let ok msg = function
  | true  -> printf "ok - %s\n" msg
  | false -> printf "not ok - %s\n" msg

let is msg a b =
  if a == b then ok msg true else ok msg false

let plan n =
  printf "1..%i\n" n
