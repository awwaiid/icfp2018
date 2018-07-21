
open Test
open Matrix
open Voxel
open Coordinate

let _ =
  plan 4;

  let c1:coordinate = 1, 2, 3 in
  let m1 = empty_matrix () in

  is "Starts void" (get m1 c1) Void;

  let m2 = set m1 c1 Full in
  is "Can be set" (get m2 c1) Full;

  let m3 = toggle m2 c1 in
  is "Toggle to Full->Void" (get m3 c1) Void;

  let m4 = toggle m3 c1 in
  is "Toggle to Void->Full" (get m4 c1) Full

