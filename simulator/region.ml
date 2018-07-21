open Printf

type region_t = Coordinate.coordinate_t * Coordinate.coordinate_t
let region_to_string (c1, c2) =
  sprintf
    "[%s, %s]"
    (Coordinate.coordinate_to_string c1)
    (Coordinate.coordinate_to_string c2)

let is_member r (x, y, z) =
  let (x1, y1, z1), (x2, y2, z2) = r in
  (min x1 x2) <= x
  && x <= (max x1 x2)
  && (min y1 y2) <= y
  && y <= (max y1 y2)
  && (min z1 z2) <= z
  && z <= (max z1 z2)

let dim ((x1, y1, z1), (x2, y2, z2)) =
  (if x1 == x2 then 0 else 1)
  +
  (if y1 == y2 then 0 else 1)
  +
  (if z1 == z2 then 0 else 1)
