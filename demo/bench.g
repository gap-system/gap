MicroSeconds := function()
  local t;
  t := CurrentTime();
  return t.tv_sec * 1000000 + t.tv_usec;
end;
Bench := function(f)
  local tstart, tend;
  tstart := MicroSeconds();
  f();
  tend := MicroSeconds();
  return (tend-tstart) * 1.0 / 1000000;
end;
