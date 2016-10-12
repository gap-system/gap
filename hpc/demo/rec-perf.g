MicroSeconds := function()
  local t;
  t := CurrentTime();
  return t.tv_sec * 1000000 + t.tv_usec;
end;

Bench := function(title, f)
  local tstart, tend;
  tstart := MicroSeconds();
  f();
  tend := MicroSeconds();
  Print(title);
  Display(tend-tstart);
end;

# Populate RNam table
for i in [1..100000] do RNamObj(i); od;

Bench("Empty loop:            ", function() local i;
  for i in [1..100000] do RNamObj(i); od; end);

r := rec();
Bench("Write plain records:   ", function() local i;
  for i in [1..100000] do ASS_REC(r, RNamObj(i), i); od; end);
Bench("Update plain records:  ", function() local i;
  for i in [1..100000] do ASS_REC(r, RNamObj(i), i); od; end);
Bench("Read plain records:    ", function() local i;
  for i in [1..100000] do ELM_REC(r, RNamObj(i)); od; end);
r := AtomicRecord();
Bench("Write atomic records:  ", function() local i;
  for i in [1..100000] do ASS_REC(r, RNamObj(i), i); od; end);
Bench("Update atomic records: ", function() local i;
  for i in [1..100000] do ASS_REC(r, RNamObj(i), i); od; end);
Bench("Read atomic records:   ",function() local i;
  for i in [1..100000] do ELM_REC(r, RNamObj(i)); od; end);
