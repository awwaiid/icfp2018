
open Printf

type coordinate_t = int * int * int
let coordinate_to_string (x, y, z) =
  sprintf "(%i,%i,%i)" x y z

type coordinate_difference = int * int * int
let coordinate_difference_to_string (x, y, z) =
  sprintf "<%i,%i,%i>" x y z

let add a b =
  let x1, y1, z1 = a in
  let x2, y2, z2 = b in
  (x1+x2), (y1+y2), (z1+z2)

let sub a b =
  let x1, y1, z1 = a in
  let x2, y2, z2 = b in
  (x1-x2), (y1-y2), (z1-z2)

let mlen (dx, dy, dz) = (abs dx) + (abs dy) + (abs dz)

let clen (dx, dy, dz) = max dx (max dy dz)

let is_linear_coordinate_difference (dx, dy, dz) =
  (dx != 0 && dy == 0 && dz == 0)
  || (dx == 0 && dy != 0 && dz == 0)
  || (dx == 0 && dy == 0 && dz != 0)

let is_short_ld ld = is_linear_coordinate_difference ld && (mlen ld) <= 5
let is_long_ld ld = is_linear_coordinate_difference ld && (mlen ld) <= 15
let is_nd d = 0 < (mlen d) && (mlen d) <= 2 && (clen d) == 1

let from_list lst =
  (List.nth lst 0),(List.nth lst 1),(List.nth lst 2)

let touches c1 c2 = mlen (sub c1 c2) == 1
