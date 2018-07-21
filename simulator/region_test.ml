
open Region
open Test

let _ =
  let r_1d:region_t = ((0,0,0), (0,0,5)) in
  is "1D region" (dim r_1d) 1;

  let r_2d:region_t = ((0,0,0), (0,12,5)) in
  is "2D region" (dim r_2d) 2;

  let r_3d:region_t = ((0,0,0), (3,3,3)) in
  is "3D region" (dim r_3d) 3;

  ok "Point inside region" (is_member r_3d (1,1,1));
  ok "Point outside region" (not (is_member r_3d (1,8,1)));

  done_testing ()
