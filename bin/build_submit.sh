for problem in FA{001..186} FR{001..115}; do
  echo "working on $problem"
  bin/model_to_json.pl --file problems/${problem}_tgt.mdl | bin/bot_trace.pl --brain Heuristic  | jq -s -c . | bin/tracifier.pl -o submissions/201807221824/${problem}.nbt
done
