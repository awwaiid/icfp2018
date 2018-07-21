
open Test
open Matrix
open Voxel
open Coordinate

let _ =

  let c1:coordinate_t = 1, 2, 3 in
  let m1 = empty_matrix () in

  is "Starts void" (get m1 c1) Void;

  let m2 = set m1 c1 Full in
  is "Can be set" (get m2 c1) Full;

  let m3 = toggle m2 c1 in
  is "Toggle to Full->Void" (get m3 c1) Void;

  let m4 = toggle m3 c1 in
  is "Toggle to Void->Full" (get m4 c1) Full;

  ok "Empty matrix is grounded" (is_grounded (empty_matrix()));

  let simple_grounded = toggle (empty_matrix()) (1,0,0) in
  ok "Simple grounded matrix" (is_grounded simple_grounded);

  let simple_ungrounded = toggle (empty_matrix()) (1,1,0) in
  ok "Simple un-grounded matrix" (not (is_grounded simple_ungrounded));

  let grounded_stack = empty_matrix () in
  let grounded_stack = toggle grounded_stack (1,0,0) in
  let grounded_stack = toggle grounded_stack (1,1,0) in
  let grounded_stack = toggle grounded_stack (1,2,0) in
  ok "Simple grounded stack" (is_grounded grounded_stack);

  let ungrounded_stack = toggle grounded_stack (1,5,0) in
  ok "Simple un-grounded stack" (not (is_grounded ungrounded_stack));

  done_testing ()
