          # They even differ only by a scalar from the base field:
          pos := PositionNonZero(newgens[1][1]);
          blpos := QuoInt(blpos+subdim-1,subdim);
          prototype := ExtractSubMatrix(newgens[1],[1..subdim],
                                        [(blpos-1)*subdim..blpos*subdim]);
          inblpos := pos - (blpos-1)*subdim;
          # now pos = (blpos-1)*subdim + inblpos and 1 < inblpos <= subdim
          homgens := [];
          for i in [1..Length(newgens)] do

