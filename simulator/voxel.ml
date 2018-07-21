
open Printf

type voxel = Full | Void

let voxel_to_string = function
  | Full -> "F"
  | Void -> "V"

let voxel_to_int = function
  | Full -> 1
  | Void -> 0

let int_to_voxel = function
  | Void -> 0
  | _    -> 1
