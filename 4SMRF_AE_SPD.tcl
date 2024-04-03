# --------------------------------------------------------------------------------
# ----------------------------------- 4SMRF_AE -----------------------------------
# --------------------------------------------------------------------------------


wipe all;
model basic -ndm 2 -ndf 3;

# Basic model variables
set global RunTime;
set global StartTime;
set global MaxRunTime;
set MaxRunTime 600.0;
set StartTime [clock seconds];
set RunTime 0.0;
set  EQ 1;  # Regular expression anchor
set  PO 0;  # Regular expression anchor
set  ShowAnimation 1;

# Ground motion information
set MainFolder "H:/MRF_results/test/4SMRF";
set GMname "th5";
set SubFolder "th5";
set GMdt 0.01;
set GMpoints 5590;
set GMduration 55.89;
set FVduration 30;
set EqSF 2.0;
set GMFile "GMs/$GMname.th";

# Sourcing subroutines
source DisplayModel3D.tcl;
source DisplayPlane.tcl;
source Spring_Zero.tcl;
source Spring_Rigid.tcl;
source ConstructPanel_Rectangle.tcl;
source DynamicAnalysisCollapseSolverX.tcl;
source PanelZone.tcl
source BeamHinge.tcl
source ColumnHinge.tcl

# Results folders
file mkdir $MainFolder;
file mkdir $MainFolder/EigenAnalysis;
file mkdir $MainFolder/$SubFolder;

# Basic parameters
set NStory 4;
set NBay 3;
set E 206000.00;
set mu 0.3;
set fy_beam 345.00;
set fy_column 345.00;
uniaxialMaterial Elastic 9 1.e-9;
uniaxialMaterial Elastic 99 1.e12;
geomTransf Linear 1;
geomTransf PDelta 2;
geomTransf Corotational 3;
set A_Stiff 1.e8;
set I_Stiff 1.e13;

# Building geometry
set Floor1 0.0;
set Floor2 4300.0;
set Floor3 8300.0;
set Floor4 12300.0;
set Floor5 16300.0;

set Axis1 0.0;
set Axis2 6100.0;
set Axis3 12200.0;
set Axis4 18300.0;
set Axis5 24400.0;

set HBuilding 16300.0;
variable HBuilding 16300.0;


# ------------------------------------ Nodes -------------------------------------

# Support nodes
node 10010100 $Axis1 $Floor1;
node 10010200 $Axis2 $Floor1;
node 10010300 $Axis3 $Floor1;
node 10010400 $Axis4 $Floor1;
node 10010500 $Axis5 $Floor1;

# Leaning column grid nodes
node 10020500 $Axis5 $Floor2;
node 10030500 $Axis5 $Floor3;
node 10040500 $Axis5 $Floor4;
node 10050500 $Axis5 $Floor5;

# Leaning column connected nodes
node 10020502 $Axis5 $Floor2;
node 10020501 $Axis5 $Floor2;
node 10030502 $Axis5 $Floor3;
node 10030501 $Axis5 $Floor3;
node 10040502 $Axis5 $Floor4;
node 10040501 $Axis5 $Floor4;
node 10050502 $Axis5 $Floor5;

# Moment frame column nodes
node 10010101 $Axis1 $Floor1;  node 10010201 $Axis2 $Floor1;  node 10010301 $Axis3 $Floor1;  node 10010401 $Axis4 $Floor1;
node 10020102 $Axis1 [expr $Floor2 - 538.48/2];  node 10020202 $Axis2 [expr $Floor2 - 538.48/2];  node 10020302 $Axis3 [expr $Floor2 - 538.48/2];  node 10020402 $Axis4 [expr $Floor2 - 538.48/2];
node 10020101 $Axis1 [expr $Floor2 + 538.48/2];  node 10020201 $Axis2 [expr $Floor2 + 538.48/2];  node 10020301 $Axis3 [expr $Floor2 + 538.48/2];  node 10020401 $Axis4 [expr $Floor2 + 538.48/2];
node 10030102 $Axis1 [expr $Floor3 - 538.48/2];  node 10030202 $Axis2 [expr $Floor3 - 538.48/2];  node 10030302 $Axis3 [expr $Floor3 - 538.48/2];  node 10030402 $Axis4 [expr $Floor3 - 538.48/2];
node 10030101 $Axis1 [expr $Floor3 + 538.48/2];  node 10030201 $Axis2 [expr $Floor3 + 538.48/2];  node 10030301 $Axis3 [expr $Floor3 + 538.48/2];  node 10030401 $Axis4 [expr $Floor3 + 538.48/2];
node 10040102 $Axis1 [expr $Floor4 - 535.94/2];  node 10040202 $Axis2 [expr $Floor4 - 535.94/2];  node 10040302 $Axis3 [expr $Floor4 - 535.94/2];  node 10040402 $Axis4 [expr $Floor4 - 535.94/2];
node 10040101 $Axis1 [expr $Floor4 + 535.94/2];  node 10040201 $Axis2 [expr $Floor4 + 535.94/2];  node 10040301 $Axis3 [expr $Floor4 + 535.94/2];  node 10040401 $Axis4 [expr $Floor4 + 535.94/2];
node 10050102 $Axis1 [expr $Floor5 - 535.94/2];  node 10050202 $Axis2 [expr $Floor5 - 535.94/2];  node 10050302 $Axis3 [expr $Floor5 - 535.94/2];  node 10050402 $Axis4 [expr $Floor5 - 535.94/2];

# Moment frame beam nodes
node 10020104 [expr $Axis1 + 644.84] $Floor2;  node 10020205 [expr $Axis2 - 644.84] $Floor2;  node 10020204 [expr $Axis2 + 644.84] $Floor2;  node 10020305 [expr $Axis3 - 644.84] $Floor2;  node 10020304 [expr $Axis3 + 644.84] $Floor2;  node 10020405 [expr $Axis4 - 644.84] $Floor2;
node 10030104 [expr $Axis1 + 644.84] $Floor3;  node 10030205 [expr $Axis2 - 644.84] $Floor3;  node 10030204 [expr $Axis2 + 644.84] $Floor3;  node 10030305 [expr $Axis3 - 644.84] $Floor3;  node 10030304 [expr $Axis3 + 644.84] $Floor3;  node 10030405 [expr $Axis4 - 644.84] $Floor3;
node 10040104 [expr $Axis1 + 606.11] $Floor4;  node 10040205 [expr $Axis2 - 606.11] $Floor4;  node 10040204 [expr $Axis2 + 606.11] $Floor4;  node 10040305 [expr $Axis3 - 606.11] $Floor4;  node 10040304 [expr $Axis3 + 606.11] $Floor4;  node 10040405 [expr $Axis4 - 606.11] $Floor4;
node 10050104 [expr $Axis1 + 606.11] $Floor5;  node 10050205 [expr $Axis2 - 606.11] $Floor5;  node 10050204 [expr $Axis2 + 606.11] $Floor5;  node 10050305 [expr $Axis3 - 606.11] $Floor5;  node 10050304 [expr $Axis3 + 606.11] $Floor5;  node 10050405 [expr $Axis4 - 606.11] $Floor5;

# Beam spring nodes (If RBS length equal zero, beam spring nodes will not be generated)
node 10020103 [expr $Axis1 + 644.84] $Floor2;  node 10020206 [expr $Axis2 - 644.84] $Floor2;  node 10020203 [expr $Axis2 + 644.84] $Floor2;  node 10020306 [expr $Axis3 - 644.84] $Floor2;  node 10020303 [expr $Axis3 + 644.84] $Floor2;  node 10020406 [expr $Axis4 - 644.84] $Floor2;
node 10030103 [expr $Axis1 + 644.84] $Floor3;  node 10030206 [expr $Axis2 - 644.84] $Floor3;  node 10030203 [expr $Axis2 + 644.84] $Floor3;  node 10030306 [expr $Axis3 - 644.84] $Floor3;  node 10030303 [expr $Axis3 + 644.84] $Floor3;  node 10030406 [expr $Axis4 - 644.84] $Floor3;
node 10040103 [expr $Axis1 + 606.11] $Floor4;  node 10040206 [expr $Axis2 - 606.11] $Floor4;  node 10040203 [expr $Axis2 + 606.11] $Floor4;  node 10040306 [expr $Axis3 - 606.11] $Floor4;  node 10040303 [expr $Axis3 + 606.11] $Floor4;  node 10040406 [expr $Axis4 - 606.11] $Floor4;
node 10050103 [expr $Axis1 + 606.11] $Floor5;  node 10050206 [expr $Axis2 - 606.11] $Floor5;  node 10050203 [expr $Axis2 + 606.11] $Floor5;  node 10050306 [expr $Axis3 - 606.11] $Floor5;  node 10050303 [expr $Axis3 + 606.11] $Floor5;  node 10050406 [expr $Axis4 - 606.11] $Floor5;

# Column splice ndoes
node 10030107 $Axis1 [expr $Floor3 + 0.5 * 4000.00];  node 10030207 $Axis2 [expr $Floor3 + 0.5 * 4000.00];  node 10030307 $Axis3 [expr $Floor3 + 0.5 * 4000.00];  node 10030407 $Axis4 [expr $Floor3 + 0.5 * 4000.00];

# Beam splice ndoes
node 10020108 [expr $Axis1 + 6100.00 / 2] $Floor2;  node 10020208 [expr $Axis2 + 6100.00 / 2] $Floor2;  node 10020308 [expr $Axis3 + 6100.00 / 2] $Floor2;
node 10030108 [expr $Axis1 + 6100.00 / 2] $Floor3;  node 10030208 [expr $Axis2 + 6100.00 / 2] $Floor3;  node 10030308 [expr $Axis3 + 6100.00 / 2] $Floor3;
node 10040108 [expr $Axis1 + 6100.00 / 2] $Floor4;  node 10040208 [expr $Axis2 + 6100.00 / 2] $Floor4;  node 10040308 [expr $Axis3 + 6100.00 / 2] $Floor4;
node 10050108 [expr $Axis1 + 6100.00 / 2] $Floor5;  node 10050208 [expr $Axis2 + 6100.00 / 2] $Floor5;  node 10050308 [expr $Axis3 + 6100.00 / 2] $Floor5;


# ----------------------------------- Elements -----------------------------------

set n 10.;

# Column elements
element elasticBeamColumn 10010101 10010101 10020102 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;  element elasticBeamColumn 10010201 10010201 10020202 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;  element elasticBeamColumn 10010301 10010301 10020302 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;  element elasticBeamColumn 10010401 10010401 10020402 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;
element elasticBeamColumn 10020101 10020101 10030102 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;  element elasticBeamColumn 10020201 10020201 10030202 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;  element elasticBeamColumn 10020301 10020301 10030302 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;  element elasticBeamColumn 10020401 10020401 10030402 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;
element elasticBeamColumn 10030102 10030101 10030107 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;  element elasticBeamColumn 10030202 10030201 10030207 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;  element elasticBeamColumn 10030302 10030301 10030307 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;  element elasticBeamColumn 10030402 10030401 10030407 19548.35 $E [expr ($n+1)/$n*1248694276.80] 2;
element elasticBeamColumn 10030103 10030107 10040102 11741.91 $E [expr ($n+1)/$n*645158709.68] 2;  element elasticBeamColumn 10030203 10030207 10040202 11741.91 $E [expr ($n+1)/$n*645158709.68] 2;  element elasticBeamColumn 10030303 10030307 10040302 11741.91 $E [expr ($n+1)/$n*645158709.68] 2;  element elasticBeamColumn 10030403 10030407 10040402 11741.91 $E [expr ($n+1)/$n*645158709.68] 2;
element elasticBeamColumn 10040101 10040101 10050102 11741.91 $E [expr ($n+1)/$n*645158709.68] 2;  element elasticBeamColumn 10040201 10040201 10050202 11741.91 $E [expr ($n+1)/$n*645158709.68] 2;  element elasticBeamColumn 10040301 10040301 10050302 11741.91 $E [expr ($n+1)/$n*645158709.68] 2;  element elasticBeamColumn 10040401 10040401 10050402 11741.91 $E [expr ($n+1)/$n*645158709.68] 2;

# Beam elements
element elasticBeamColumn 10020111 10020103 10020108 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10020112 10020108 10020206 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10020211 10020203 10020208 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10020212 10020208 10020306 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10020311 10020303 10020308 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10020312 10020308 10020406 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;
element elasticBeamColumn 10030111 10030103 10030108 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10030112 10030108 10030206 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10030211 10030203 10030208 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10030212 10030208 10030306 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10030311 10030303 10030308 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;  element elasticBeamColumn 10030312 10030308 10030406 13870.94 $E [expr ($n+1)/$n*665970280.96] 2;
element elasticBeamColumn 10040111 10040103 10040108 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10040112 10040108 10040206 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10040211 10040203 10040208 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10040212 10040208 10040306 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10040311 10040303 10040308 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10040312 10040308 10040406 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;
element elasticBeamColumn 10050111 10050103 10050108 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10050112 10050108 10050206 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10050211 10050203 10050208 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10050212 10050208 10050306 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10050311 10050303 10050308 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;  element elasticBeamColumn 10050312 10050308 10050406 10774.17 $E [expr ($n+1)/$n*486990767.95] 2;

# Panel zones
# PanelNone Floor Axis X Y E mu fy_column A_stiff I_stiff d_col d_beam tp tf bf transfTag type_ position check ""
PanelZone 2 1 $Axis1 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 622.30 538.48 13.97 24.89 228.60 2 1 "L";  PanelZone 2 2 $Axis2 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 622.30 538.48 21.87 24.89 228.60 2 1 "I";  PanelZone 2 3 $Axis3 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 622.30 538.48 21.87 24.89 228.60 2 1 "I";  PanelZone 2 4 $Axis4 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 622.30 538.48 13.97 24.89 228.60 2 1 "R";
PanelZone 3 1 $Axis1 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 622.30 538.48 13.97 24.89 228.60 2 1 "L";  PanelZone 3 2 $Axis2 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 622.30 538.48 21.87 24.89 228.60 2 1 "I";  PanelZone 3 3 $Axis3 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 622.30 538.48 21.87 24.89 228.60 2 1 "I";  PanelZone 3 4 $Axis4 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 622.30 538.48 13.97 24.89 228.60 2 1 "R";
PanelZone 4 1 $Axis1 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 601.98 535.94 10.92 14.99 178.82 2 1 "L";  PanelZone 4 2 $Axis2 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 601.98 535.94 18.82 14.99 178.82 2 1 "I";  PanelZone 4 3 $Axis3 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 601.98 535.94 18.82 14.99 178.82 2 1 "I";  PanelZone 4 4 $Axis4 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 601.98 535.94 10.92 14.99 178.82 2 1 "R";
PanelZone 5 1 $Axis1 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 601.98 535.94 10.92 14.99 178.82 2 1 "LT";  PanelZone 5 2 $Axis2 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 601.98 535.94 18.82 14.99 178.82 2 1 "T";  PanelZone 5 3 $Axis3 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 601.98 535.94 18.82 14.99 178.82 2 1 "T";  PanelZone 5 4 $Axis4 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 601.98 535.94 10.92 14.99 178.82 2 1 "RT";

# RBS elements (If RBS length equal zero, RBS element will not be generated)
element elasticBeamColumn 10020105 11020104 10020103 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10020106 10020206 11020202 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10020205 11020204 10020203 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10020206 10020306 11020302 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10020305 11020304 10020303 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10020306 10020406 11020402 13870.94 $E 665970280.96 2;
element elasticBeamColumn 10030105 11030104 10030103 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10030106 10030206 11030202 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10030205 11030204 10030203 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10030206 10030306 11030302 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10030305 11030304 10030303 13870.94 $E 665970280.96 2;  element elasticBeamColumn 10030306 10030406 11030402 13870.94 $E 665970280.96 2;
element elasticBeamColumn 10040105 11040104 10040103 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10040106 10040206 11040202 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10040205 11040204 10040203 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10040206 10040306 11040302 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10040305 11040304 10040303 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10040306 10040406 11040402 10774.17 $E 486990767.95 2;
element elasticBeamColumn 10050105 11050104 10050103 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10050106 10050206 11050202 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10050205 11050204 10050203 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10050206 10050306 11050302 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10050305 11050304 10050303 10774.17 $E 486990767.95 2;  element elasticBeamColumn 10050306 10050406 11050402 10774.17 $E 486990767.95 2;

# Beam hinges
# BeamHinge SpringID NodeI NodeJ E fy_beam Ix d htw bftf ry L Ls Lb My type_ {check ""}
BeamHinge 10020109 10020103 10020104 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10020210 10020205 10020206 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10020209 10020203 10020204 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10020310 10020305 10020306 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10020309 10020303 10020304 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10020410 10020405 10020406 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;
BeamHinge 10030109 10030103 10030104 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10030210 10030205 10030206 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10030209 10030203 10030204 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10030310 10030305 10030306 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10030309 10030303 10030304 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;  BeamHinge 10030410 10030405 10030406 $E $fy_beam 665970280.96 538.48 41.14 5.61 46.03 5477.7 2738.8 2738.8 972408377.76 1;
BeamHinge 10040109 10040103 10040104 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10040210 10040205 10040206 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10040209 10040203 10040204 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10040310 10040305 10040306 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10040309 10040303 10040304 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10040410 10040405 10040406 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;
BeamHinge 10050109 10050103 10050104 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10050210 10050205 10050206 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10050209 10050203 10050204 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10050310 10050305 10050306 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10050309 10050303 10050304 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;  BeamHinge 10050410 10050405 10050406 $E $fy_beam 486990767.95 535.94 46.42 5.05 34.38 5498.0 2749.0 2749.0 729306283.32 1;

# Column hinges
# Column SpringID NodeI NodeJ E Ix d htw ry L Lb My PPy SF_PPy pinned check ""
ColumnHinge 10010107 10010100 10010101 $E 1248694276.80 622.30 39.16 50.34 4030.76 4030.76 1582990382.40 0.1062 1.25 1;  ColumnHinge 10010207 10010200 10010201 $E 1248694276.80 622.30 39.16 50.34 4030.76 4030.76 1582990382.40 0.0708 1.25 1;  ColumnHinge 10010307 10010300 10010301 $E 1248694276.80 622.30 39.16 50.34 4030.76 4030.76 1582990382.40 0.0708 1.25 1;  ColumnHinge 10010407 10010400 10010401 $E 1248694276.80 622.30 39.16 50.34 4030.76 4030.76 1582990382.40 0.1062 1.25 1;
ColumnHinge 10020108 10020102 11020101 $E 1248694276.80 622.30 39.16 50.34 4030.76 4030.76 1582990382.40 0.1062 1.25 1;  ColumnHinge 10020208 10020202 11020201 $E 1248694276.80 622.30 39.16 50.34 4030.76 4030.76 1582990382.40 0.0708 1.25 1;  ColumnHinge 10020308 10020302 11020301 $E 1248694276.80 622.30 39.16 50.34 4030.76 4030.76 1582990382.40 0.0708 1.25 1;  ColumnHinge 10020408 10020402 11020401 $E 1248694276.80 622.30 39.16 50.34 4030.76 4030.76 1582990382.40 0.1062 1.25 1;
ColumnHinge 10020107 11020103 10020101 $E 1248694276.80 622.30 39.16 50.34 3461.52 3461.52 1582990382.40 0.0783 1.25 1;  ColumnHinge 10020207 11020203 10020201 $E 1248694276.80 622.30 39.16 50.34 3461.52 3461.52 1582990382.40 0.0522 1.25 1;  ColumnHinge 10020307 11020303 10020301 $E 1248694276.80 622.30 39.16 50.34 3461.52 3461.52 1582990382.40 0.0522 1.25 1;  ColumnHinge 10020407 11020403 10020401 $E 1248694276.80 622.30 39.16 50.34 3461.52 3461.52 1582990382.40 0.0783 1.25 1;
ColumnHinge 10030108 10030102 11030101 $E 1248694276.80 622.30 39.16 50.34 3461.52 3461.52 1582990382.40 0.0783 1.25 1;  ColumnHinge 10030208 10030202 11030201 $E 1248694276.80 622.30 39.16 50.34 3461.52 3461.52 1582990382.40 0.0522 1.25 1;  ColumnHinge 10030308 10030302 11030301 $E 1248694276.80 622.30 39.16 50.34 3461.52 3461.52 1582990382.40 0.0522 1.25 1;  ColumnHinge 10030408 10030402 11030401 $E 1248694276.80 622.30 39.16 50.34 3461.52 3461.52 1582990382.40 0.0783 1.25 1;
ColumnHinge 10030107 11030103 10030101 $E 1248694276.80 622.30 39.16 50.34 3462.79 3462.79 1582990382.40 0.0506 1.25 1;  ColumnHinge 10030207 11030203 10030201 $E 1248694276.80 622.30 39.16 50.34 3462.79 3462.79 1582990382.40 0.0337 1.25 1;  ColumnHinge 10030307 11030303 10030301 $E 1248694276.80 622.30 39.16 50.34 3462.79 3462.79 1582990382.40 0.0337 1.25 1;  ColumnHinge 10030407 11030403 10030401 $E 1248694276.80 622.30 39.16 50.34 3462.79 3462.79 1582990382.40 0.0506 1.25 1;
ColumnHinge 10040108 10040102 11040101 $E 645158709.68 601.98 50.05 34.97 3462.79 3462.79 864991173.24 0.0843 1.25 1;  ColumnHinge 10040208 10040202 11040201 $E 645158709.68 601.98 50.05 34.97 3462.79 3462.79 864991173.24 0.0562 1.25 1;  ColumnHinge 10040308 10040302 11040301 $E 645158709.68 601.98 50.05 34.97 3462.79 3462.79 864991173.24 0.0562 1.25 1;  ColumnHinge 10040408 10040402 11040401 $E 645158709.68 601.98 50.05 34.97 3462.79 3462.79 864991173.24 0.0843 1.25 1;
ColumnHinge 10040107 11040103 10040101 $E 645158709.68 601.98 50.05 34.97 3464.06 3464.06 864991173.24 0.0382 1.25 1;  ColumnHinge 10040207 11040203 10040201 $E 645158709.68 601.98 50.05 34.97 3464.06 3464.06 864991173.24 0.0255 1.25 1;  ColumnHinge 10040307 11040303 10040301 $E 645158709.68 601.98 50.05 34.97 3464.06 3464.06 864991173.24 0.0255 1.25 1;  ColumnHinge 10040407 11040403 10040401 $E 645158709.68 601.98 50.05 34.97 3464.06 3464.06 864991173.24 0.0382 1.25 1;
ColumnHinge 10050108 10050102 11050101 $E 645158709.68 601.98 50.05 34.97 3464.06 3464.06 864991173.24 0.0382 1.25 1;  ColumnHinge 10050208 10050202 11050201 $E 645158709.68 601.98 50.05 34.97 3464.06 3464.06 864991173.24 0.0255 1.25 1;  ColumnHinge 10050308 10050302 11050301 $E 645158709.68 601.98 50.05 34.97 3464.06 3464.06 864991173.24 0.0255 1.25 1;  ColumnHinge 10050408 10050402 11050401 $E 645158709.68 601.98 50.05 34.97 3464.06 3464.06 864991173.24 0.0382 1.25 1;

# Rigid links
element truss 10020404 11020404 10020500 $A_Stiff 99;
element truss 10030404 11030404 10030500 $A_Stiff 99;
element truss 10040404 11040404 10040500 $A_Stiff 99;
element truss 10050404 11050404 10050500 $A_Stiff 99;

# Leaning column
element elasticBeamColumn 10010501 10010500 10020502 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10020501 10020501 10030502 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10030501 10030501 10040502 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10040501 10040501 10050502 $A_Stiff $E $I_Stiff 2;

# Leaning column hinges
Spring_Rigid 10020508 10020502 10020500;
Spring_Zero 10020507 10020500 10020501;
Spring_Rigid 10030508 10030502 10030500;
Spring_Zero 10030507 10030500 10030501;
Spring_Rigid 10040508 10040502 10040500;
Spring_Zero 10040507 10040500 10040501;
Spring_Rigid 10050508 10050502 10050500;

# --------------------------------- Constraints ----------------------------------

# Support
fix 10010100 1 1 1;
fix 10010200 1 1 1;
fix 10010300 1 1 1;
fix 10010400 1 1 1;
fix 10010500 1 1 0;

# Soil constraint
# (No soil constraint)

# Rigid diaphragm
equalDOF 11020204 11020104 1;  equalDOF 11020204 11020304 1;  equalDOF 11020204 11020404 1;
equalDOF 11030204 11030104 1;  equalDOF 11030204 11030304 1;  equalDOF 11030204 11030404 1;
equalDOF 11040204 11040104 1;  equalDOF 11040204 11040304 1;  equalDOF 11040204 11040404 1;
equalDOF 11050204 11050104 1;  equalDOF 11050204 11050304 1;  equalDOF 11050204 11050404 1;

# ------------------------------------ SPD ---------------------------------------
node 120 9150 4000;# node 121 9150 4000;
node 220 9150 8000;# node 221 9150 8000;
node 320 9150 12000;# node 321 9150 12000;
node 420 9150 16000;# node 421 9150 16000;

uniaxialMaterial Steel02 1 450e3 420e3 0.005 18.5 0.91 0.15 0.007 1 0.007 1;  # 0
uniaxialMaterial Steel02 2 360e3 450e3 0.004 18.5 0.907 0.15 0.01 1 0.01 1;  # 45
uniaxialMaterial BoucWen 3 0.028 350.66e3 2 0.215 0.215 1 0 0 0;  # 0
uniaxialMaterial BoucWen 4 0.028 350.66e3 2 0.126 0.126 1 0 0 0;  # 45
uniaxialMaterial MinMax 11 1 -min -40 -max 40;
uniaxialMaterial MinMax 22 2 -min -40 -max 40;
uniaxialMaterial MinMax 33 3 -min -40 -max 40;
uniaxialMaterial MinMax 44 4 -min -40 -max 40;
set SPD_tag 22;

# story-1
element elasticBeamColumn 101 10010200 120 $A_Stiff $E $I_Stiff 1 -release 1;
element elasticBeamColumn 102 10010300 120 $A_Stiff $E $I_Stiff 1 -release 1;
element twoNodeLink 104 120 10020208 -mat $SPD_tag -dir 2;
# story-2
element elasticBeamColumn 201 11020209 220 $A_Stiff $E $I_Stiff 1 -release 1;
element elasticBeamColumn 202 11020308 220 $A_Stiff $E $I_Stiff 1 -release 1;
element twoNodeLink 204 220 10030208 -mat $SPD_tag -dir 2;
# story-3
element elasticBeamColumn 301 11030209 320 $A_Stiff $E $I_Stiff 1 -release 1;
element elasticBeamColumn 302 11030308 320 $A_Stiff $E $I_Stiff 1 -release 1;
element twoNodeLink 304 320 10040208 -mat $SPD_tag -dir 2;
# story-4
element elasticBeamColumn 401 11040209 420 $A_Stiff $E $I_Stiff 1 -release 1;
element elasticBeamColumn 402 11040308 420 $A_Stiff $E $I_Stiff 1 -release 1;
element twoNodeLink 404 420 10050208 -mat $SPD_tag -dir 2;

# # recorder Element -file $MainFolder/$SubFolder/SPD1.out -ele 104 material 1 stressStrain;
recorder Element -file $MainFolder/$SubFolder/SPD1.out -ele 104 material 1 stressStrain;
recorder Element -file $MainFolder/$SubFolder/SPD2.out -ele 204 material 1 stressStrain;
recorder Element -file $MainFolder/$SubFolder/SPD3.out -ele 304 material 1 stressStrain;
recorder Element -file $MainFolder/$SubFolder/SPD4.out -ele 404 material 1 stressStrain;

# ---------------------------------- Recorders -----------------------------------

# Mode properties
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode1.out -node 11020204 11030204 11040204 11050204 -dof 1 "eigen 1";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode2.out -node 11020204 11030204 11040204 11050204 -dof 1 "eigen 2";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode3.out -node 11020204 11030204 11040204 11050204 -dof 1 "eigen 3";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode4.out -node 11020204 11030204 11040204 11050204 -dof 1 "eigen 4";

# Time
recorder Node -file $MainFolder/$SubFolder/Time.out -time -node 10010100 -dof 1 disp;

# Support reactions
recorder Node -file $MainFolder/$SubFolder/Support1.out -node 10010100 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support2.out -node 10010200 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support3.out -node 10010300 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support4.out -node 10010400 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support5.out -node 10010500 -dof 1 2 3 reaction;

# Story drift ratio
recorder Drift -file $MainFolder/$SubFolder/SDR1_MF.out -iNode 10010100 -jNode 11020204 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR2_MF.out -iNode 11020204 -jNode 11030204 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR3_MF.out -iNode 11030204 -jNode 11040204 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR4_MF.out -iNode 11040204 -jNode 11050204 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDRALL_MF.out -iNode 10010100 -jNode 11050204 -dof 1 -perpDirn 2;

# Floor acceleration
recorder Node -file $MainFolder/$SubFolder/RFA1_MF.out -node 10010100 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA2_MF.out -node 11020204 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA3_MF.out -node 11030204 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA4_MF.out -node 11040204 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA5_MF.out -node 11050204 -dof 1 accel;

# Floor velocity
recorder Node -file $MainFolder/$SubFolder/RFV1_MF.out -node 10010100 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV2_MF.out -node 11020204 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV3_MF.out -node 11030204 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV4_MF.out -node 11040204 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV5_MF.out -node 11050204 -dof 1 vel;

# Floor displacement
recorder Node -file $MainFolder/$SubFolder/Disp1_MF.out -node 10010100 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp2_MF.out -node 11020204 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp3_MF.out -node 11030204 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp4_MF.out -node 11040204 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp5_MF.out -node 11050204 -dof 1 disp;

# Column forces
recorder Element -file $MainFolder/$SubFolder/Column11.out -ele 10010101 force;  recorder Element -file $MainFolder/$SubFolder/Column12.out -ele 10010201 force;  recorder Element -file $MainFolder/$SubFolder/Column13.out -ele 10010301 force;  recorder Element -file $MainFolder/$SubFolder/Column14.out -ele 10010401 force;
recorder Element -file $MainFolder/$SubFolder/Column21.out -ele 10020101 force;  recorder Element -file $MainFolder/$SubFolder/Column22.out -ele 10020201 force;  recorder Element -file $MainFolder/$SubFolder/Column23.out -ele 10020301 force;  recorder Element -file $MainFolder/$SubFolder/Column24.out -ele 10020401 force;
recorder Element -file $MainFolder/$SubFolder/Column31.out -ele 10030102 force;  recorder Element -file $MainFolder/$SubFolder/Column32.out -ele 10030202 force;  recorder Element -file $MainFolder/$SubFolder/Column33.out -ele 10030302 force;  recorder Element -file $MainFolder/$SubFolder/Column34.out -ele 10030402 force;
recorder Element -file $MainFolder/$SubFolder/Column41.out -ele 10040101 force;  recorder Element -file $MainFolder/$SubFolder/Column42.out -ele 10040201 force;  recorder Element -file $MainFolder/$SubFolder/Column43.out -ele 10040301 force;  recorder Element -file $MainFolder/$SubFolder/Column44.out -ele 10040401 force;

# Column springs forces
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_F.out -ele 10010107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring12T_F.out -ele 10010207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring13T_F.out -ele 10010307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring14T_F.out -ele 10010407 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_F.out -ele 10020108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring22B_F.out -ele 10020208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring23B_F.out -ele 10020308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring24B_F.out -ele 10020408 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_F.out -ele 10020107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring22T_F.out -ele 10020207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring23T_F.out -ele 10020307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring24T_F.out -ele 10020407 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_F.out -ele 10030108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring32B_F.out -ele 10030208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring33B_F.out -ele 10030308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring34B_F.out -ele 10030408 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_F.out -ele 10030107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring32T_F.out -ele 10030207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring33T_F.out -ele 10030307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring34T_F.out -ele 10030407 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_F.out -ele 10040108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring42B_F.out -ele 10040208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring43B_F.out -ele 10040308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring44B_F.out -ele 10040408 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring41T_F.out -ele 10040107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring42T_F.out -ele 10040207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring43T_F.out -ele 10040307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring44T_F.out -ele 10040407 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring51B_F.out -ele 10050108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring52B_F.out -ele 10050208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring53B_F.out -ele 10050308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring54B_F.out -ele 10050408 force;

# Column springs rotations
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_D.out -ele 10010107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring12T_D.out -ele 10010207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring13T_D.out -ele 10010307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring14T_D.out -ele 10010407 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_D.out -ele 10020108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring22B_D.out -ele 10020208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring23B_D.out -ele 10020308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring24B_D.out -ele 10020408 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_D.out -ele 10020107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring22T_D.out -ele 10020207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring23T_D.out -ele 10020307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring24T_D.out -ele 10020407 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_D.out -ele 10030108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring32B_D.out -ele 10030208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring33B_D.out -ele 10030308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring34B_D.out -ele 10030408 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_D.out -ele 10030107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring32T_D.out -ele 10030207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring33T_D.out -ele 10030307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring34T_D.out -ele 10030407 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_D.out -ele 10040108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring42B_D.out -ele 10040208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring43B_D.out -ele 10040308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring44B_D.out -ele 10040408 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring41T_D.out -ele 10040107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring42T_D.out -ele 10040207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring43T_D.out -ele 10040307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring44T_D.out -ele 10040407 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring51B_D.out -ele 10050108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring52B_D.out -ele 10050208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring53B_D.out -ele 10050308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring54B_D.out -ele 10050408 deformation;

# Beam springs forces
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_F.out -ele 10020109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_F.out -ele 10020210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_F.out -ele 10020209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_F.out -ele 10020310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_F.out -ele 10020309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_F.out -ele 10020410 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_F.out -ele 10030109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_F.out -ele 10030210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_F.out -ele 10030209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_F.out -ele 10030310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_F.out -ele 10030309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_F.out -ele 10030410 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_F.out -ele 10040109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_F.out -ele 10040210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_F.out -ele 10040209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_F.out -ele 10040310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_F.out -ele 10040309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_F.out -ele 10040410 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring51R_F.out -ele 10050109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring52L_F.out -ele 10050210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring52R_F.out -ele 10050209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring53L_F.out -ele 10050310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring53R_F.out -ele 10050309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring54L_F.out -ele 10050410 force;

# Beam springs rotations
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_D.out -ele 10020109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_D.out -ele 10020210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_D.out -ele 10020209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_D.out -ele 10020310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_D.out -ele 10020309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_D.out -ele 10020410 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_D.out -ele 10030109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_D.out -ele 10030210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_D.out -ele 10030209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_D.out -ele 10030310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_D.out -ele 10030309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_D.out -ele 10030410 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_D.out -ele 10040109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_D.out -ele 10040210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_D.out -ele 10040209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_D.out -ele 10040310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_D.out -ele 10040309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_D.out -ele 10040410 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring51R_D.out -ele 10050109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring52L_D.out -ele 10050210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring52R_D.out -ele 10050209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring53L_D.out -ele 10050310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring53R_D.out -ele 10050309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring54L_D.out -ele 10050410 deformation;

# Panel zone spring forces (if any)
recorder Element -file $MainFolder/$SubFolder/PZ21_F.out -ele 11020100 force;  recorder Element -file $MainFolder/$SubFolder/PZ22_F.out -ele 11020200 force;  recorder Element -file $MainFolder/$SubFolder/PZ23_F.out -ele 11020300 force;  recorder Element -file $MainFolder/$SubFolder/PZ24_F.out -ele 11020400 force;
recorder Element -file $MainFolder/$SubFolder/PZ31_F.out -ele 11030100 force;  recorder Element -file $MainFolder/$SubFolder/PZ32_F.out -ele 11030200 force;  recorder Element -file $MainFolder/$SubFolder/PZ33_F.out -ele 11030300 force;  recorder Element -file $MainFolder/$SubFolder/PZ34_F.out -ele 11030400 force;
recorder Element -file $MainFolder/$SubFolder/PZ41_F.out -ele 11040100 force;  recorder Element -file $MainFolder/$SubFolder/PZ42_F.out -ele 11040200 force;  recorder Element -file $MainFolder/$SubFolder/PZ43_F.out -ele 11040300 force;  recorder Element -file $MainFolder/$SubFolder/PZ44_F.out -ele 11040400 force;
recorder Element -file $MainFolder/$SubFolder/PZ51_F.out -ele 11050100 force;  recorder Element -file $MainFolder/$SubFolder/PZ52_F.out -ele 11050200 force;  recorder Element -file $MainFolder/$SubFolder/PZ53_F.out -ele 11050300 force;  recorder Element -file $MainFolder/$SubFolder/PZ54_F.out -ele 11050400 force;

# Panel zone spring deforamtions (if any)
recorder Element -file $MainFolder/$SubFolder/PZ21_D.out -ele 11020100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ22_D.out -ele 11020200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ23_D.out -ele 11020300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ24_D.out -ele 11020400 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ31_D.out -ele 11030100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ32_D.out -ele 11030200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ33_D.out -ele 11030300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ34_D.out -ele 11030400 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ41_D.out -ele 11040100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ42_D.out -ele 11040200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ43_D.out -ele 11040300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ44_D.out -ele 11040400 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ51_D.out -ele 11050100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ52_D.out -ele 11050200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ53_D.out -ele 11050300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ54_D.out -ele 11050400 deformation;

# ------------------------------------- Mass -------------------------------------

# Moment frame mass
set g 9810.0;
mass 11020104 16.895 1.e-9 1.e-9;  mass 11020204 11.263 1.e-9 1.e-9;  mass 11020304 11.263 1.e-9 1.e-9;  mass 11020404 16.895 1.e-9 1.e-9;
mass 11030104 16.727 1.e-9 1.e-9;  mass 11030204 11.151 1.e-9 1.e-9;  mass 11030304 11.151 1.e-9 1.e-9;  mass 11030404 16.727 1.e-9 1.e-9;
mass 11040104 16.727 1.e-9 1.e-9;  mass 11040204 11.151 1.e-9 1.e-9;  mass 11040304 11.151 1.e-9 1.e-9;  mass 11040404 16.727 1.e-9 1.e-9;
mass 11050104 14.486 1.e-9 1.e-9;  mass 11050204 9.657 1.e-9 1.e-9;  mass 11050304 9.657 1.e-9 1.e-9;  mass 11050404 14.486 1.e-9 1.e-9;

# Leaning column mass
mass 10020500 266.601 1.e-9 1.e-9;
mass 10030500 265.817 1.e-9 1.e-9;
mass 10040500 265.817 1.e-9 1.e-9;
mass 10050500 255.360 1.e-9 1.e-9;


# -------------------------------- Eigen analysis --------------------------------

set pi [expr 2.0*asin(1.0)];
set nEigen 4
set lambdaN [eigen [expr $nEigen]];
set lambda1 [lindex $lambdaN 0];
set lambda2 [lindex $lambdaN 1];
set lambda3 [lindex $lambdaN 2];
set lambda4 [lindex $lambdaN 3];
set w1 [expr pow($lambda1, 0.5)];
set w2 [expr pow($lambda2, 0.5)];
set w3 [expr pow($lambda3, 0.5)];
set w4 [expr pow($lambda4, 0.5)];
set T1 [expr round(2.0*$pi/$w1 *1000.)/1000.];
set T2 [expr round(2.0*$pi/$w2 *1000.)/1000.];
set T3 [expr round(2.0*$pi/$w3 *1000.)/1000.];
set T4 [expr round(2.0*$pi/$w4 *1000.)/1000.];
puts "T1 = $T1 s";
puts "T2 = $T2 s";
puts "T3 = $T3 s";

set fileX [open "$MainFolder/EigenAnalysis/EigenPeriod.out" w];
puts $fileX $T1;
puts $fileX $T2;
puts $fileX $T3;
puts $fileX $T4;
close $fileX;


# --------------------------- Static gravity analysis ----------------------------

pattern Plain 100 Linear {

    # Moment frame loads
    load 11020101 0. -188314.9 0.;      load 11020201 0. -125543.6 0.;      load 11020301 0. -125543.6 0.;      load 11020401 0. -188314.9 0.;
    load 11030101 0. -186667.9 0.;      load 11030201 0. -124445.6 0.;      load 11030301 0. -124445.6 0.;      load 11030401 0. -186667.9 0.;
    load 11040101 0. -186667.9 0.;      load 11040201 0. -124445.6 0.;      load 11040301 0. -124445.6 0.;      load 11040401 0. -186667.9 0.;
    load 11050101 0. -154661.2 0.;      load 11050201 0. -103107.8 0.;      load 11050301 0. -103107.8 0.;      load 11050401 0. -154661.2 0.;

    # gravity frame loads
    load 10020500 0. -3078215.5 0.;
    load 10030500 0. -3070145.2 0.;
    load 10040500 0. -3070145.2 0.;
    load 10050500 0. -2761607.2 0.;

}

constraints Plain;
numberer RCM;
system BandGeneral;
test NormDispIncr 1.0e-5 60;
algorithm Newton;
integrator LoadControl 0.1;
analysis Static;
analyze 10;
loadConst -time 0.0;


# ---------------------------- Time history analysis -----------------------------

if {$ShowAnimation == 1} {DisplayModel3D DeformedShape 5.00 100 100 1600 1000};

if {$EQ == 1} {

    # Rayleigh damping
    set zeta 0.02;
    set a0 [expr $zeta*2.0*$w1*$w3/($w1 + $w3)];
    set a1 [expr $zeta*2.0/($w1 + $w3)];
    set a1_mod [expr $a1*(1.0+$n)/$n];
    set beam_Ids [list 10020111 10020112 10020211 10020212 10020311 10020312 10030111 10030112 10030211 10030212 10030311 10030312 10040111 10040112 10040211 10040212 10040311 10040312 10050111 10050112 10050211 10050212 10050311 10050312];
    set column_Ids [list 10010101 10010201 10010301 10010401 10020101 10020201 10020301 10020401 10030102 10030103 10030202 10030203 10030302 10030303 10030402 10030403 10040101 10040201 10040301 10040401];
    set mass_Ids [list 11020104 11020204 11020304 11020404 11030104 11030204 11030304 11030404 11040104 11040204 11040304 11040404 11050104 11050204 11050304 11050404 10020500 10030500 10040500 10050500];
    # region 1 -ele {*}$beam_Ids -rayleigh 0.0 0.0 $a1_mod 0.0;
    # region 2 -ele {*}$column_Ids -rayleigh 0.0 0.0 $a1_mod 0.0;
    # region 3 -ele {*}$mass_Ids -rayleigh $a0 0.0 0.0 0.0;
    rayleigh $a0 0.0 $a1 0.0;

    # Ground motion acceleration file input
    set AccelSeries "Series -dt $GMdt -filePath $GMFile -factor [expr $EqSF * $g]";
    pattern UniformExcitation 200 1 -accel $AccelSeries;
    set MF_FloorNodes [list 11020204 11030204 11040204 11050204];
    set GMduration [expr $GMdt*$GMpoints];
    set NumSteps [expr round(($GMduration + $FVduration)/$GMdt)];
    set totTime [expr $GMdt*$NumSteps];
    set dtAnalysis [expr 1.0*$GMdt];
    DynamicAnalysisCollapseSolverX $GMdt $dtAnalysis $totTime $NStory 0.15 $MF_FloorNodes $MF_FloorNodes 4300.0 4000.0 1 $StartTime $MaxRunTime $GMname;

}


# ------------------------------ Pushover analysis -------------------------------

if {$PO == 1} {

    set m2 322.918;
    set m3 321.573;
    set m4 321.573;
    set m5 303.647;

    set file [open "$MainFolder/EigenAnalysis/EigenVectorsMode1.out" r];
    set first_line [gets $file];
    close $file
    set mode_list [split $first_line];
    set F2 [expr $m2 * [lindex $mode_list 0]];
    set F3 [expr $m3 * [lindex $mode_list 1]];
    set F4 [expr $m4 * [lindex $mode_list 2]];
    set F5 [expr $m5 * [lindex $mode_list 3]];
    pattern Plain 222 Linear {
        load 11020204 $F2 0.0 0.0;
        load 11030204 $F3 0.0 0.0;
        load 11040204 $F4 0.0 0.0;
        load 11050204 $F5 0.0 0.0;
    };
    set CtrlNode 11050204;
    set CtrlDOF 1;
    set Dmax [expr 0.100*$Floor5];
    set Dincr [expr 0.5];
    set Nsteps [expr int($Dmax/$Dincr)];
    set ok 0;
    set controlDisp 0.0;
    source LibAnalysisStaticParameters.tcl;
    source SolutionAlgorithm.tcl;

}

wipe all;

# ----------------------------- Building information -----------------------------
#
# Moment resisting frame model information
# Frame name: 4SMRF_AE
# Generation time: 2024-04-02 22:29:04.694835
# All units are in [N, mm, t]
# 
# 
# --------------- 1. Building Geometry ---------------
# 
# Building height: 16300
# Number of story: 4
# Number of bays: 3
# Plane dimensions [mm]: 42700 x 30500
# Number of moment frames: 2
# External column tributary area [mm]: 9150.0 x 3050.0
# Internal column tributary area [mm]: 6100 x 3050.0
# 
# 
# --------------- 2. Structural Components ---------------
# 
# Beam sections:
#  Floor  Bay-1  Bay-2  Bay-3
#      2 W21x73 W21x73 W21x73
#      3 W21x73 W21x73 W21x73
#      4 W21x57 W21x57 W21x57
#      5 W21x57 W21x57 W21x57
# 
# Column sections:
#  Story  Axis-1  Axis-2  Axis-3  Axis-4
#      1 W24x103 W24x103 W24x103 W24x103
#      2 W24x103 W24x103 W24x103 W24x103
#      3 W24x103 W24x103 W24x103 W24x103
#      4  W24x62  W24x62  W24x62  W24x62
# 
# Stories with column splices: 3
# 
# Doubler plate thickness [mm]:
#  Floor  Axis-1  Axis-2  Axis-3  Axis-4
#      2       0     7.9     7.9       0
#      3       0     7.9     7.9       0
#      4       0     7.9     7.9       0
#      5       0     7.9     7.9       0
# 
# 
# --------------- 3. Load and Material ---------------
# 
# Material properties:
# 	Young's modulus [MPa]: 206000
# 	Nominal yield strength of beams [MPa]: 345
# 	Nominal yield strength of columns [MPa]: 345
# 	Possion ratio: 0.3
# 
# Load [MPa]:
# Story/Floor   Dead    Live  Cladding
#         1/2 0.0043 0.00240    0.0012
#         2/3 0.0043 0.00240    0.0012
#         3/4 0.0043 0.00240    0.0012
#         4/5 0.0043 0.00096    0.0012
# 
# Load and mass combination coefficients:
#         Dead  Live  Cladding
# Weight  1.05  0.25      1.05
# Mass    1.00  0.00      1.00
# 
# Axial compressive ratio of columns:
# Story   Axis-1   Axis-2   Axis-3   Axis-4
#    1b 0.106212 0.070808 0.070808 0.106212
#    1t 0.106212 0.070808 0.070808 0.106212
#    2b 0.078289 0.052193 0.052193 0.078289
#    2t 0.078289 0.052193 0.052193 0.078289
#    3b 0.050611 0.033741 0.033741 0.050611
#    3t 0.084259 0.056173 0.056173 0.084259
#    4b 0.038179 0.025453 0.025453 0.038179
#    4t 0.038179 0.025453 0.025453 0.038179
# 
# Seiemic weight of considered 2D frame: 14367.82 kN
# Seiemic mass of considered 2D frame: 1269.71 t
# 
# 
# --------------- 4. Connection and Boundary Condition ---------------
# 
# Base support: Fixed
# Beam-to-column connection: Reduced beam section (RBS)
# Reduced beam section (RBS) parameters: 0.625, 0.75, 0.25
# Consider panel zone deformation: Yes (Parallelogram)
# 

