proc TNL_SelfCentering {SpringID NodeI NodeJ A} {

set scale [expr $A / 30.127 / 1000];

uniaxialMaterial SelfCentering [expr $SpringID * 1000] 156250.0 -161892.0 84375.0 0.13 37.1 37.1 0.056;  # (unit: mm)
uniaxialMaterial SelfCentering [expr $SpringID * 1001] 194489.0 165420.0 1013288.0 0.75 37.1 37.1 0.056;  # (unit: mm)
uniaxialMaterial Parallel $SpringID [expr $SpringID * 1000] [expr $SpringID * 1001] -factors $scale $scale;

element twoNodeLink $SpringID $NodeI $NodeJ -mat $SpringID -dir 1;


}