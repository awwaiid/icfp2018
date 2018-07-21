
open Coordinate
open Test

let _ =
  plan 1;

  let c1:coordinate_t = 1, 2, 3 in
  let c2:coordinate_t = 1, 2, 3 in
  let x, y, z = add c1 c2 in
  ok "Simple add" (x == 2 && y == 4 && z == 6)


