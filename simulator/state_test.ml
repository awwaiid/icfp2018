
open Test
open State
open Printf

let _ =
  let empty_state = initial () in
  let s1 = { empty_state with resolution = 20 } in

  is "Starts with no energy used" s1.energy 0;
  is "Starts with no voxels" (Matrix.voxel_count s1.matrix) 0;

  let commands = Stream.of_list [
    Yojson.Basic.from_string "{ cmd: \"wait\", sequence: 1 }"
  ] in
  let s2 = execute_step s1 commands in
  is "Waiting costs energy" s2.energy 24020;

  let commands = Stream.of_list [
    Yojson.Basic.from_string "{ cmd: \"fill\", sequence: 1, nd: [0,0,1] }"
  ] in
  let s2 = execute_step s1 commands in
  is "Fill energy" s2.energy 24032;
  is "Has one voxel" (Matrix.voxel_count s2.matrix) 1;
  is "Original state still has zero voxels" (Matrix.voxel_count s1.matrix) 0;

  done_testing ()
