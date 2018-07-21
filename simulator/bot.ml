
open Printf
open Coordinate

type bot_t = {
  bid: int;
  mutable pos: coordinate_t;
  seeds: int list;
}

let initial_bot () = {
  bid = 1;
  pos = 0, 0, 0;
  seeds = [2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20];
}

let bot_to_string bot =
  sprintf "{bid: %i, pos: %s}" bot.bid (coordinate_to_string bot.pos)
