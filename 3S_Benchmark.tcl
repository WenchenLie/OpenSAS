# --------------------------------------------------------------------------------
# --------------------------------- 3S_Benchmark ---------------------------------
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
set NStory 3;
set NBay 4;
set E 206000.00;
set mu 0.3;
set fy_beam 248.00;
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
set Floor2 3960.0;
set Floor3 7920.0;
set Floor4 11880.0;

set Axis1 0.0;
set Axis2 9150.0;
set Axis3 18300.0;
set Axis4 27450.0;
set Axis5 36600.0;
set Axis6 45750.0;

set HBuilding 11880.0;
variable HBuilding 11880.0;


# ------------------------------------ Nodes -------------------------------------

# Support nodes
node 10010100 $Axis1 $Floor1;
node 10010200 $Axis2 $Floor1;
node 10010300 $Axis3 $Floor1;
node 10010400 $Axis4 $Floor1;
node 10010500 $Axis5 $Floor1;
node 10010600 $Axis6 $Floor1;

# Leaning column grid nodes
node 10020600 $Axis6 $Floor2;
node 10030600 $Axis6 $Floor3;
node 10040600 $Axis6 $Floor4;

# Leaning column connected nodes
node 10020602 $Axis6 $Floor2;
node 10020601 $Axis6 $Floor2;
node 10030602 $Axis6 $Floor3;
node 10030601 $Axis6 $Floor3;
node 10040602 $Axis6 $Floor4;

# Moment frame column nodes
node 10010101 $Axis1 $Floor1;  node 10010201 $Axis2 $Floor1;  node 10010301 $Axis3 $Floor1;  node 10010401 $Axis4 $Floor1;  node 10010501 $Axis5 $Floor1;
node 10020102 $Axis1 [expr $Floor2 - 835.66/2];  node 10020202 $Axis2 [expr $Floor2 - 835.66/2];  node 10020302 $Axis3 [expr $Floor2 - 835.66/2];  node 10020402 $Axis4 [expr $Floor2 - 798.83/2];  node 10020502 $Axis5 [expr $Floor2 - 762.00/2];
node 10020101 $Axis1 [expr $Floor2 + 835.66/2];  node 10020201 $Axis2 [expr $Floor2 + 835.66/2];  node 10020301 $Axis3 [expr $Floor2 + 835.66/2];  node 10020401 $Axis4 [expr $Floor2 + 798.83/2];  node 10020501 $Axis5 [expr $Floor2 + 762.00/2];
node 10030102 $Axis1 [expr $Floor3 - 762.00/2];  node 10030202 $Axis2 [expr $Floor3 - 762.00/2];  node 10030302 $Axis3 [expr $Floor3 - 762.00/2];  node 10030402 $Axis4 [expr $Floor3 - 762.00/2];  node 10030502 $Axis5 [expr $Floor3 - 762.00/2];
node 10030101 $Axis1 [expr $Floor3 + 762.00/2];  node 10030201 $Axis2 [expr $Floor3 + 762.00/2];  node 10030301 $Axis3 [expr $Floor3 + 762.00/2];  node 10030401 $Axis4 [expr $Floor3 + 762.00/2];  node 10030501 $Axis5 [expr $Floor3 + 762.00/2];
node 10040102 $Axis1 [expr $Floor4 - 601.98/2];  node 10040202 $Axis2 [expr $Floor4 - 601.98/2];  node 10040302 $Axis3 [expr $Floor4 - 601.98/2];  node 10040402 $Axis4 [expr $Floor4 - 601.98/2];  node 10040502 $Axis5 [expr $Floor4 - 601.98/2];

# Moment frame beam nodes
node 10020104 [expr $Axis1 + 208.28] $Floor2;  node 10020205 [expr $Axis2 - 217.17] $Floor2;  node 10020204 [expr $Axis2 + 217.17] $Floor2;  node 10020305 [expr $Axis3 - 217.17] $Floor2;  node 10020304 [expr $Axis3 + 217.17] $Floor2;  node 10020405 [expr $Axis4 - 217.17] $Floor2;  node 10020404 [expr $Axis4 + 217.17] $Floor2;  node 10020505 [expr $Axis5 - 208.28] $Floor2;
node 10030104 [expr $Axis1 + 208.28] $Floor3;  node 10030205 [expr $Axis2 - 217.17] $Floor3;  node 10030204 [expr $Axis2 + 217.17] $Floor3;  node 10030305 [expr $Axis3 - 217.17] $Floor3;  node 10030304 [expr $Axis3 + 217.17] $Floor3;  node 10030405 [expr $Axis4 - 217.17] $Floor3;  node 10030404 [expr $Axis4 + 217.17] $Floor3;  node 10030505 [expr $Axis5 - 208.28] $Floor3;
node 10040104 [expr $Axis1 + 208.28] $Floor4;  node 10040205 [expr $Axis2 - 217.17] $Floor4;  node 10040204 [expr $Axis2 + 217.17] $Floor4;  node 10040305 [expr $Axis3 - 217.17] $Floor4;  node 10040304 [expr $Axis3 + 217.17] $Floor4;  node 10040405 [expr $Axis4 - 217.17] $Floor4;  node 10040404 [expr $Axis4 + 217.17] $Floor4;  node 10040505 [expr $Axis5 - 208.28] $Floor4;

# Beam spring nodes (If RBS length equal zero, beam spring nodes will not be generated)




# Column splice ndoes

# Beam splice ndoes





# ----------------------------------- Elements -----------------------------------

set n 10.;

# Column elements
element elasticBeamColumn 10010101 10010101 10020102 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10010201 10010201 10020202 58967.62 $E [expr ($n+1)/$n*1802282072.85] 2;  element elasticBeamColumn 10010301 10010301 10020302 58967.62 $E [expr ($n+1)/$n*1802282072.85] 2;  element elasticBeamColumn 10010401 10010401 10020402 58967.62 $E [expr ($n+1)/$n*1802282072.85] 2;  element elasticBeamColumn 10010501 10010501 10020502 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;
element elasticBeamColumn 10020101 10020101 10030102 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10020201 10020201 10030202 58967.62 $E [expr ($n+1)/$n*1802282072.85] 2;  element elasticBeamColumn 10020301 10020301 10030302 58967.62 $E [expr ($n+1)/$n*1802282072.85] 2;  element elasticBeamColumn 10020401 10020401 10030402 58967.62 $E [expr ($n+1)/$n*1802282072.85] 2;  element elasticBeamColumn 10020501 10020501 10030502 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;
element elasticBeamColumn 10030101 10030101 10040102 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10030201 10030201 10040202 58967.62 $E [expr ($n+1)/$n*1802282072.85] 2;  element elasticBeamColumn 10030301 10030301 10040302 58967.62 $E [expr ($n+1)/$n*1802282072.85] 2;  element elasticBeamColumn 10030401 10030401 10040402 58967.62 $E [expr ($n+1)/$n*1802282072.85] 2;  element elasticBeamColumn 10030501 10030501 10040502 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;

# Beam elements
element elasticBeamColumn 10020104 10020104 10020205 22387.05 $E [expr ($n+1)/$n*2455765411.04] 2;  element elasticBeamColumn 10020204 10020204 10020305 22387.05 $E [expr ($n+1)/$n*2455765411.04] 2;  element elasticBeamColumn 10020304 10020304 10020405 22387.05 $E [expr ($n+1)/$n*2455765411.04] 2;  element elasticBeamColumn 10020404 10020404 10020505 22064.47 $E [expr ($n+1)/$n*2052020928.21] 2;
element elasticBeamColumn 10030104 10030104 10030205 22064.47 $E [expr ($n+1)/$n*2052020928.21] 2;  element elasticBeamColumn 10030204 10030204 10030305 22064.47 $E [expr ($n+1)/$n*2052020928.21] 2;  element elasticBeamColumn 10030304 10030304 10030405 22064.47 $E [expr ($n+1)/$n*2052020928.21] 2;  element elasticBeamColumn 10030404 10030404 10030505 22064.47 $E [expr ($n+1)/$n*2052020928.21] 2;
element elasticBeamColumn 10040104 10040104 10040205 12967.72 $E [expr ($n+1)/$n*761703508.85] 2;  element elasticBeamColumn 10040204 10040204 10040305 12967.72 $E [expr ($n+1)/$n*761703508.85] 2;  element elasticBeamColumn 10040304 10040304 10040405 12967.72 $E [expr ($n+1)/$n*761703508.85] 2;  element elasticBeamColumn 10040404 10040404 10040505 12967.72 $E [expr ($n+1)/$n*761703508.85] 2;

# Panel zones
# PanelNone Floor Axis X Y E mu fy_column A_stiff I_stiff d_col d_beam tp tf bf transfTag type_ position check ""
PanelZone 2 1 $Axis1 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 835.66 29.97 48.01 406.40 2 1 "L";  PanelZone 2 2 $Axis2 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 434.34 835.66 35.81 57.40 411.48 2 1 "I";  PanelZone 2 3 $Axis3 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 434.34 835.66 35.81 57.40 411.48 2 1 "I";  PanelZone 2 4 $Axis4 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 434.34 798.83 35.81 57.40 411.48 2 1 "I";  PanelZone 2 5 $Axis5 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 762.00 29.97 48.01 406.40 2 1 "R";
PanelZone 3 1 $Axis1 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 762.00 29.97 48.01 406.40 2 1 "L";  PanelZone 3 2 $Axis2 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 434.34 762.00 35.81 57.40 411.48 2 1 "I";  PanelZone 3 3 $Axis3 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 434.34 762.00 35.81 57.40 411.48 2 1 "I";  PanelZone 3 4 $Axis4 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 434.34 762.00 35.81 57.40 411.48 2 1 "I";  PanelZone 3 5 $Axis5 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 762.00 29.97 48.01 406.40 2 1 "R";
PanelZone 4 1 $Axis1 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 601.98 29.97 48.01 406.40 2 1 "LT";  PanelZone 4 2 $Axis2 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 434.34 601.98 35.81 57.40 411.48 2 1 "T";  PanelZone 4 3 $Axis3 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 434.34 601.98 35.81 57.40 411.48 2 1 "T";  PanelZone 4 4 $Axis4 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 434.34 601.98 35.81 57.40 411.48 2 1 "T";  PanelZone 4 5 $Axis5 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 601.98 29.97 48.01 406.40 2 1 "RT";

# RBS elements (If RBS length equal zero, RBS element will not be generated)




# Beam hinges
# BeamHinge SpringID NodeI NodeJ E fy_beam Ix d htw bftf ry L Ls Lb My type_ {check ""}
BeamHinge 10020109 11020104 10020104 $E $fy_beam 2455765411.04 835.66 54.58 7.77 58.96 8724.5 4362.3 4362.3 1686556626.88 2;  BeamHinge 10020210 10020205 11020202 $E $fy_beam 2455765411.04 835.66 54.58 7.77 58.96 8724.5 4362.3 4362.3 1686556626.88 2;  BeamHinge 10020209 11020204 10020204 $E $fy_beam 2455765411.04 835.66 54.58 7.77 58.96 8715.7 4357.8 4357.8 1686556626.88 2;  BeamHinge 10020310 10020305 11020302 $E $fy_beam 2455765411.04 835.66 54.58 7.77 58.96 8715.7 4357.8 4357.8 1686556626.88 2;  BeamHinge 10020309 11020304 10020304 $E $fy_beam 2455765411.04 835.66 54.58 7.77 58.96 8715.7 4357.8 4357.8 1686556626.88 2;  BeamHinge 10020410 10020405 11020402 $E $fy_beam 2455765411.04 835.66 54.58 7.77 58.96 8715.7 4357.8 4357.8 1686556626.88 2;  BeamHinge 10020409 11020404 10020404 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8724.5 4362.3 4362.3 1536188927.62 2;  BeamHinge 10020510 10020505 11020502 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8724.5 4362.3 4362.3 1536188927.62 2;
BeamHinge 10030109 11030104 10030104 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8724.5 4362.3 4362.3 1536188927.62 2;  BeamHinge 10030210 10030205 11030202 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8724.5 4362.3 4362.3 1536188927.62 2;  BeamHinge 10030209 11030204 10030204 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8715.7 4357.8 4357.8 1536188927.62 2;  BeamHinge 10030310 10030305 11030302 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8715.7 4357.8 4357.8 1536188927.62 2;  BeamHinge 10030309 11030304 10030304 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8715.7 4357.8 4357.8 1536188927.62 2;  BeamHinge 10030410 10030405 11030402 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8715.7 4357.8 4357.8 1536188927.62 2;  BeamHinge 10030409 11030404 10030404 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8724.5 4362.3 4362.3 1536188927.62 2;  BeamHinge 10030510 10030505 11030502 $E $fy_beam 2052020928.21 762.00 47.79 6.18 55.62 8724.5 4362.3 4362.3 1536188927.62 2;
BeamHinge 10040109 11040104 10040104 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8724.5 4362.3 4362.3 719326561.34 2;  BeamHinge 10040210 10040205 11040202 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8724.5 4362.3 4362.3 719326561.34 2;  BeamHinge 10040209 11040204 10040204 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8715.7 4357.8 4357.8 719326561.34 2;  BeamHinge 10040310 10040305 11040302 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8715.7 4357.8 4357.8 719326561.34 2;  BeamHinge 10040309 11040304 10040304 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8715.7 4357.8 4357.8 719326561.34 2;  BeamHinge 10040410 10040405 11040402 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8715.7 4357.8 4357.8 719326561.34 2;  BeamHinge 10040409 11040404 10040404 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8724.5 4362.3 4362.3 719326561.34 2;  BeamHinge 10040510 10040505 11040502 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8724.5 4362.3 4362.3 719326561.34 2;

# Column hinges
# Column SpringID NodeI NodeJ E Ix d htw ry L Lb My PPy SF_PPy pinned check ""
ColumnHinge 10010107 10010100 10010101 $E 1415186847.04 416.56 9.68 104.92 3542.17 3542.17 2753272557.96 0.0000 1.25 1;  ColumnHinge 10010207 10010200 10010201 $E 1802282072.85 434.34 8.07 106.60 3542.17 3542.17 3409082859.24 0.0000 1.25 1;  ColumnHinge 10010307 10010300 10010301 $E 1802282072.85 434.34 8.07 106.60 3542.17 3542.17 3409082859.24 0.0000 1.25 1;  ColumnHinge 10010407 10010400 10010401 $E 1802282072.85 434.34 8.07 106.60 3560.59 3560.59 3409082859.24 0.0000 1.25 1;  ColumnHinge 10010507 10010500 10010501 $E 1415186847.04 416.56 9.68 104.92 3579.00 3579.00 2753272557.96 0.0000 1.25 1;
ColumnHinge 10020108 10020102 11020101 $E 1415186847.04 416.56 9.68 104.92 3542.17 3542.17 2753272557.96 0.0000 1.25 1;  ColumnHinge 10020208 10020202 11020201 $E 1802282072.85 434.34 8.07 106.60 3542.17 3542.17 3409082859.24 0.0000 1.25 1;  ColumnHinge 10020308 10020302 11020301 $E 1802282072.85 434.34 8.07 106.60 3542.17 3542.17 3409082859.24 0.0000 1.25 1;  ColumnHinge 10020408 10020402 11020401 $E 1802282072.85 434.34 8.07 106.60 3560.59 3560.59 3409082859.24 0.0000 1.25 1;  ColumnHinge 10020508 10020502 11020501 $E 1415186847.04 416.56 9.68 104.92 3579.00 3579.00 2753272557.96 0.0000 1.25 1;
ColumnHinge 10020107 11020103 10020101 $E 1415186847.04 416.56 9.68 104.92 3161.17 3161.17 2753272557.96 0.0000 1.25 1;  ColumnHinge 10020207 11020203 10020201 $E 1802282072.85 434.34 8.07 106.60 3161.17 3161.17 3409082859.24 0.0000 1.25 1;  ColumnHinge 10020307 11020303 10020301 $E 1802282072.85 434.34 8.07 106.60 3161.17 3161.17 3409082859.24 0.0000 1.25 1;  ColumnHinge 10020407 11020403 10020401 $E 1802282072.85 434.34 8.07 106.60 3179.59 3179.59 3409082859.24 0.0000 1.25 1;  ColumnHinge 10020507 11020503 10020501 $E 1415186847.04 416.56 9.68 104.92 3198.00 3198.00 2753272557.96 0.0000 1.25 1;
ColumnHinge 10030108 10030102 11030101 $E 1415186847.04 416.56 9.68 104.92 3161.17 3161.17 2753272557.96 0.0000 1.25 1;  ColumnHinge 10030208 10030202 11030201 $E 1802282072.85 434.34 8.07 106.60 3161.17 3161.17 3409082859.24 0.0000 1.25 1;  ColumnHinge 10030308 10030302 11030301 $E 1802282072.85 434.34 8.07 106.60 3161.17 3161.17 3409082859.24 0.0000 1.25 1;  ColumnHinge 10030408 10030402 11030401 $E 1802282072.85 434.34 8.07 106.60 3179.59 3179.59 3409082859.24 0.0000 1.25 1;  ColumnHinge 10030508 10030502 11030501 $E 1415186847.04 416.56 9.68 104.92 3198.00 3198.00 2753272557.96 0.0000 1.25 1;
ColumnHinge 10030107 11030103 10030101 $E 1415186847.04 416.56 9.68 104.92 3278.01 3278.01 2753272557.96 0.0000 1.25 1;  ColumnHinge 10030207 11030203 10030201 $E 1802282072.85 434.34 8.07 106.60 3278.01 3278.01 3409082859.24 0.0000 1.25 1;  ColumnHinge 10030307 11030303 10030301 $E 1802282072.85 434.34 8.07 106.60 3278.01 3278.01 3409082859.24 0.0000 1.25 1;  ColumnHinge 10030407 11030403 10030401 $E 1802282072.85 434.34 8.07 106.60 3278.01 3278.01 3409082859.24 0.0000 1.25 1;  ColumnHinge 10030507 11030503 10030501 $E 1415186847.04 416.56 9.68 104.92 3278.01 3278.01 2753272557.96 0.0000 1.25 1;
ColumnHinge 10040108 10040102 11040101 $E 1415186847.04 416.56 9.68 104.92 3278.01 3278.01 2753272557.96 0.0000 1.25 1;  ColumnHinge 10040208 10040202 11040201 $E 1802282072.85 434.34 8.07 106.60 3278.01 3278.01 3409082859.24 0.0000 1.25 1;  ColumnHinge 10040308 10040302 11040301 $E 1802282072.85 434.34 8.07 106.60 3278.01 3278.01 3409082859.24 0.0000 1.25 1;  ColumnHinge 10040408 10040402 11040401 $E 1802282072.85 434.34 8.07 106.60 3278.01 3278.01 3409082859.24 0.0000 1.25 1;  ColumnHinge 10040508 10040502 11040501 $E 1415186847.04 416.56 9.68 104.92 3278.01 3278.01 2753272557.96 0.0000 1.25 1;

# Rigid links
element truss 10020504 11020504 10020600 $A_Stiff 99;
element truss 10030504 11030504 10030600 $A_Stiff 99;
element truss 10040504 11040504 10040600 $A_Stiff 99;

# Leaning column
element elasticBeamColumn 10010601 10010600 10020602 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10020601 10020601 10030602 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10030601 10030601 10040602 $A_Stiff $E $I_Stiff 2;

# Leaning column hinges
Spring_Rigid 10020608 10020602 10020600;
Spring_Zero 10020607 10020600 10020601;
Spring_Rigid 10030608 10030602 10030600;
Spring_Zero 10030607 10030600 10030601;
Spring_Rigid 10040608 10040602 10040600;

# --------------------------------- Constraints ----------------------------------

# Support
fix 10010100 1 1 1;
fix 10010200 1 1 1;
fix 10010300 1 1 1;
fix 10010400 1 1 1;
fix 10010500 1 1 1;
fix 10010600 1 1 0;

# Soil constraint
# (No soil constraint)

# Rigid diaphragm
equalDOF 11020304 11020104 1;  equalDOF 11020304 11020204 1;  equalDOF 11020304 11020404 1;  equalDOF 11020304 11020504 1;
equalDOF 11030304 11030104 1;  equalDOF 11030304 11030204 1;  equalDOF 11030304 11030404 1;  equalDOF 11030304 11030504 1;
equalDOF 11040304 11040104 1;  equalDOF 11040304 11040204 1;  equalDOF 11040304 11040404 1;  equalDOF 11040304 11040504 1;

# ---------------------------------- Recorders -----------------------------------

# Mode properties
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode1.out -node 11020304 11030304 11040304 -dof 1 "eigen 1";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode2.out -node 11020304 11030304 11040304 -dof 1 "eigen 2";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode3.out -node 11020304 11030304 11040304 -dof 1 "eigen 3";

# Time
recorder Node -file $MainFolder/$SubFolder/Time.out -time -node 10010100 -dof 1 disp;

# Support reactions
recorder Node -file $MainFolder/$SubFolder/Support1.out -node 10010100 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support2.out -node 10010200 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support3.out -node 10010300 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support4.out -node 10010400 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support5.out -node 10010500 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support6.out -node 10010600 -dof 1 2 3 reaction;

# Story drift ratio
recorder Drift -file $MainFolder/$SubFolder/SDR1_MF.out -iNode 10010100 -jNode 11020304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR2_MF.out -iNode 11020304 -jNode 11030304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR3_MF.out -iNode 11030304 -jNode 11040304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDRALL_MF.out -iNode 10010100 -jNode 11040304 -dof 1 -perpDirn 2;

# Floor acceleration
recorder Node -file $MainFolder/$SubFolder/RFA1_MF.out -node 10010100 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA2_MF.out -node 11020304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA3_MF.out -node 11030304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA4_MF.out -node 11040304 -dof 1 accel;

# Floor velocity
recorder Node -file $MainFolder/$SubFolder/RFV1_MF.out -node 10010100 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV2_MF.out -node 11020304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV3_MF.out -node 11030304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV4_MF.out -node 11040304 -dof 1 vel;

# Floor displacement
recorder Node -file $MainFolder/$SubFolder/Disp1_MF.out -node 10010100 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp2_MF.out -node 11020304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp3_MF.out -node 11030304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp4_MF.out -node 11040304 -dof 1 disp;

# Column forces
recorder Element -file $MainFolder/$SubFolder/Column11.out -ele 10010101 force;  recorder Element -file $MainFolder/$SubFolder/Column12.out -ele 10010201 force;  recorder Element -file $MainFolder/$SubFolder/Column13.out -ele 10010301 force;  recorder Element -file $MainFolder/$SubFolder/Column14.out -ele 10010401 force;  recorder Element -file $MainFolder/$SubFolder/Column15.out -ele 10010501 force;
recorder Element -file $MainFolder/$SubFolder/Column21.out -ele 10020101 force;  recorder Element -file $MainFolder/$SubFolder/Column22.out -ele 10020201 force;  recorder Element -file $MainFolder/$SubFolder/Column23.out -ele 10020301 force;  recorder Element -file $MainFolder/$SubFolder/Column24.out -ele 10020401 force;  recorder Element -file $MainFolder/$SubFolder/Column25.out -ele 10020501 force;
recorder Element -file $MainFolder/$SubFolder/Column31.out -ele 10030101 force;  recorder Element -file $MainFolder/$SubFolder/Column32.out -ele 10030201 force;  recorder Element -file $MainFolder/$SubFolder/Column33.out -ele 10030301 force;  recorder Element -file $MainFolder/$SubFolder/Column34.out -ele 10030401 force;  recorder Element -file $MainFolder/$SubFolder/Column35.out -ele 10030501 force;

# Column springs forces
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_F.out -ele 10010107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring12T_F.out -ele 10010207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring13T_F.out -ele 10010307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring14T_F.out -ele 10010407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring15T_F.out -ele 10010507 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_F.out -ele 10020108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring22B_F.out -ele 10020208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring23B_F.out -ele 10020308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring24B_F.out -ele 10020408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring25B_F.out -ele 10020508 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_F.out -ele 10020107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring22T_F.out -ele 10020207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring23T_F.out -ele 10020307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring24T_F.out -ele 10020407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring25T_F.out -ele 10020507 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_F.out -ele 10030108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring32B_F.out -ele 10030208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring33B_F.out -ele 10030308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring34B_F.out -ele 10030408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring35B_F.out -ele 10030508 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_F.out -ele 10030107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring32T_F.out -ele 10030207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring33T_F.out -ele 10030307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring34T_F.out -ele 10030407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring35T_F.out -ele 10030507 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_F.out -ele 10040108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring42B_F.out -ele 10040208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring43B_F.out -ele 10040308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring44B_F.out -ele 10040408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring45B_F.out -ele 10040508 force;

# Column springs rotations
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_D.out -ele 10010107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring12T_D.out -ele 10010207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring13T_D.out -ele 10010307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring14T_D.out -ele 10010407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring15T_D.out -ele 10010507 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_D.out -ele 10020108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring22B_D.out -ele 10020208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring23B_D.out -ele 10020308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring24B_D.out -ele 10020408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring25B_D.out -ele 10020508 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_D.out -ele 10020107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring22T_D.out -ele 10020207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring23T_D.out -ele 10020307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring24T_D.out -ele 10020407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring25T_D.out -ele 10020507 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_D.out -ele 10030108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring32B_D.out -ele 10030208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring33B_D.out -ele 10030308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring34B_D.out -ele 10030408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring35B_D.out -ele 10030508 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_D.out -ele 10030107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring32T_D.out -ele 10030207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring33T_D.out -ele 10030307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring34T_D.out -ele 10030407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring35T_D.out -ele 10030507 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_D.out -ele 10040108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring42B_D.out -ele 10040208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring43B_D.out -ele 10040308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring44B_D.out -ele 10040408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring45B_D.out -ele 10040508 deformation;

# Beam springs forces
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_F.out -ele 10020109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_F.out -ele 10020210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_F.out -ele 10020209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_F.out -ele 10020310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_F.out -ele 10020309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_F.out -ele 10020410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24R_F.out -ele 10020409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring25L_F.out -ele 10020510 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_F.out -ele 10030109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_F.out -ele 10030210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_F.out -ele 10030209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_F.out -ele 10030310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_F.out -ele 10030309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_F.out -ele 10030410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34R_F.out -ele 10030409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring35L_F.out -ele 10030510 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_F.out -ele 10040109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_F.out -ele 10040210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_F.out -ele 10040209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_F.out -ele 10040310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_F.out -ele 10040309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_F.out -ele 10040410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44R_F.out -ele 10040409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring45L_F.out -ele 10040510 force;

# Beam springs rotations
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_D.out -ele 10020109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_D.out -ele 10020210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_D.out -ele 10020209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_D.out -ele 10020310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_D.out -ele 10020309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_D.out -ele 10020410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24R_D.out -ele 10020409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring25L_D.out -ele 10020510 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_D.out -ele 10030109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_D.out -ele 10030210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_D.out -ele 10030209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_D.out -ele 10030310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_D.out -ele 10030309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_D.out -ele 10030410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34R_D.out -ele 10030409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring35L_D.out -ele 10030510 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_D.out -ele 10040109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_D.out -ele 10040210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_D.out -ele 10040209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_D.out -ele 10040310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_D.out -ele 10040309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_D.out -ele 10040410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44R_D.out -ele 10040409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring45L_D.out -ele 10040510 deformation;

# Panel zone spring forces (if any)
recorder Element -file $MainFolder/$SubFolder/PZ21_F.out -ele 11020100 force;  recorder Element -file $MainFolder/$SubFolder/PZ22_F.out -ele 11020200 force;  recorder Element -file $MainFolder/$SubFolder/PZ23_F.out -ele 11020300 force;  recorder Element -file $MainFolder/$SubFolder/PZ24_F.out -ele 11020400 force;  recorder Element -file $MainFolder/$SubFolder/PZ25_F.out -ele 11020500 force;
recorder Element -file $MainFolder/$SubFolder/PZ31_F.out -ele 11030100 force;  recorder Element -file $MainFolder/$SubFolder/PZ32_F.out -ele 11030200 force;  recorder Element -file $MainFolder/$SubFolder/PZ33_F.out -ele 11030300 force;  recorder Element -file $MainFolder/$SubFolder/PZ34_F.out -ele 11030400 force;  recorder Element -file $MainFolder/$SubFolder/PZ35_F.out -ele 11030500 force;
recorder Element -file $MainFolder/$SubFolder/PZ41_F.out -ele 11040100 force;  recorder Element -file $MainFolder/$SubFolder/PZ42_F.out -ele 11040200 force;  recorder Element -file $MainFolder/$SubFolder/PZ43_F.out -ele 11040300 force;  recorder Element -file $MainFolder/$SubFolder/PZ44_F.out -ele 11040400 force;  recorder Element -file $MainFolder/$SubFolder/PZ45_F.out -ele 11040500 force;

# Panel zone spring deforamtions (if any)
recorder Element -file $MainFolder/$SubFolder/PZ21_D.out -ele 11020100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ22_D.out -ele 11020200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ23_D.out -ele 11020300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ24_D.out -ele 11020400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ25_D.out -ele 11020500 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ31_D.out -ele 11030100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ32_D.out -ele 11030200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ33_D.out -ele 11030300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ34_D.out -ele 11030400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ35_D.out -ele 11030500 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ41_D.out -ele 11040100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ42_D.out -ele 11040200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ43_D.out -ele 11040300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ44_D.out -ele 11040400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ45_D.out -ele 11040500 deformation;

# ------------------------------------- Mass -------------------------------------

# Moment frame mass
set g 9810.0;
mass 11020104 95.800 1.e-9 1.e-9;  mass 11020204 95.800 1.e-9 1.e-9;  mass 11020304 95.800 1.e-9 1.e-9;  mass 11020404 95.800 1.e-9 1.e-9;  mass 11020504 95.800 1.e-9 1.e-9;
mass 11030104 95.800 1.e-9 1.e-9;  mass 11030204 95.800 1.e-9 1.e-9;  mass 11030304 95.800 1.e-9 1.e-9;  mass 11030404 95.800 1.e-9 1.e-9;  mass 11030504 95.800 1.e-9 1.e-9;
mass 11040104 104.000 1.e-9 1.e-9;  mass 11040204 104.000 1.e-9 1.e-9;  mass 11040304 104.000 1.e-9 1.e-9;  mass 11040404 104.000 1.e-9 1.e-9;  mass 11040504 104.000 1.e-9 1.e-9;

# Leaning column mass
mass 10020600 0.000 1.e-9 1.e-9;
mass 10030600 0.000 1.e-9 1.e-9;
mass 10040600 0.000 1.e-9 1.e-9;


# -------------------------------- Eigen analysis --------------------------------

set pi [expr 2.0*asin(1.0)];
set nEigen 3
set lambdaN [eigen [expr $nEigen]];
set lambda1 [lindex $lambdaN 0];
set lambda2 [lindex $lambdaN 1];
set lambda3 [lindex $lambdaN 2];
set w1 [expr pow($lambda1, 0.5)];
set w2 [expr pow($lambda2, 0.5)];
set w3 [expr pow($lambda3, 0.5)];
set T1 [expr round(2.0*$pi/$w1 *1000.)/1000.];
set T2 [expr round(2.0*$pi/$w2 *1000.)/1000.];
set T3 [expr round(2.0*$pi/$w3 *1000.)/1000.];
puts "T1 = $T1 s";
puts "T2 = $T2 s";
puts "T3 = $T3 s";

set fileX [open "$MainFolder/EigenAnalysis/EigenPeriod.out" w];
puts $fileX $T1;
puts $fileX $T2;
puts $fileX $T3;
close $fileX;


# --------------------------- Static gravity analysis ----------------------------

pattern Plain 100 Linear {

    # Moment frame loads
    load 11020101 0. -958000.0 0.;      load 11020201 0. -958000.0 0.;      load 11020301 0. -958000.0 0.;      load 11020401 0. -958000.0 0.;      load 11020501 0. -958000.0 0.;
    load 11030101 0. -958000.0 0.;      load 11030201 0. -958000.0 0.;      load 11030301 0. -958000.0 0.;      load 11030401 0. -958000.0 0.;      load 11030501 0. -958000.0 0.;
    load 11040101 0. -1040000.0 0.;      load 11040201 0. -1040000.0 0.;      load 11040301 0. -1040000.0 0.;      load 11040401 0. -1040000.0 0.;      load 11040501 0. -1040000.0 0.;

    # gravity frame loads
    load 10020600 0. -0.3 0.;
    load 10030600 0. -0.3 0.;
    load 10040600 0. -0.2 0.;

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
    set beam_Ids [list 10020104 10020204 10020304 10020404 10030104 10030204 10030304 10030404 10040104 10040204 10040304 10040404];
    set column_Ids [list 10010101 10010201 10010301 10010401 10010501 10020101 10020201 10020301 10020401 10020501 10030101 10030201 10030301 10030401 10030501];
    set mass_Ids [list 11020104 11020204 11020304 11030104 11030204 11030304 11040104 11040204 11040304 10020600 10030600 10040600];
    # region 1 -ele {*}$beam_Ids -rayleigh 0.0 0.0 $a1_mod 0.0;
    # region 2 -ele {*}$column_Ids -rayleigh 0.0 0.0 $a1_mod 0.0;
    # region 3 -ele {*}$mass_Ids -rayleigh $a0 0.0 0.0 0.0;
    rayleigh $a0 0.0 $a1 0.0;

    # Ground motion acceleration file input
    set AccelSeries "Series -dt $GMdt -filePath $GMFile -factor [expr $EqSF * $g]";
    pattern UniformExcitation 200 1 -accel $AccelSeries;
    set MF_FloorNodes [list 11020304 11030304 11040304];
    set GMduration [expr $GMdt*$GMpoints];
    set NumSteps [expr round(($GMduration + $FVduration)/$GMdt)];
    set totTime [expr $GMdt*$NumSteps];
    set dtAnalysis [expr 1.0*$GMdt];
    DynamicAnalysisCollapseSolverX $GMdt $dtAnalysis $totTime $NStory 0.15 $MF_FloorNodes $MF_FloorNodes 3960.0 3960.0 1 $StartTime $MaxRunTime $GMname;

}


# ------------------------------ Pushover analysis -------------------------------

if {$PO == 1} {

    set m2 479.000;
    set m3 479.000;
    set m4 520.000;

    set file [open "$MainFolder/EigenAnalysis/EigenVectorsMode1.out" r];
    set first_line [gets $file];
    close $file
    set mode_list [split $first_line];
    set F2 [expr $m2 * [lindex $mode_list 0]];
    set F3 [expr $m3 * [lindex $mode_list 1]];
    set F4 [expr $m4 * [lindex $mode_list 2]];
    pattern Plain 222 Linear {
        load 11020304 $F2 0.0 0.0;
        load 11030304 $F3 0.0 0.0;
        load 11040304 $F4 0.0 0.0;
    };
    set CtrlNode 11040304;
    set CtrlDOF 1;
    set Dmax [expr 0.100*$Floor4];
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
# Frame name: 3S_Benchmark
# Generation time: 2024-03-31 20:47:22.277410
# All units are in [N, mm, t]
# 
# 
# --------------- 1. Building Geometry ---------------
# 
# Building height: 11880
# Number of story: 3
# Number of bays: 4
# Plane dimensions [mm]: 36600 x 36600
# Number of moment frames: 5
# External column tributary area [mm]: 4575.0 x 4575.0
# Internal column tributary area [mm]: 9150 x 4575.0
# 
# 
# --------------- 2. Structural Components ---------------
# 
# Beam sections:
#  Floor   Bay-1   Bay-2   Bay-3   Bay-4
#      2 W33x118 W33x118 W33x118 W30x116
#      3 W30x116 W30x116 W30x116 W30x116
#      4  W24x68  W24x68  W24x68  W24x68
# 
# Column sections:
#  Story  Axis-1  Axis-2  Axis-3  Axis-4  Axis-5
#      1 W14x257 W14x311 W14x311 W14x311 W14x257
#      2 W14x257 W14x311 W14x311 W14x311 W14x257
#      3 W14x257 W14x311 W14x311 W14x311 W14x257
# 
# Stories with column splices: None
# 
# Doubler plate thickness [mm]:
#  Floor  Axis-1  Axis-2  Axis-3  Axis-4  Axis-5
#      2       0       0       0       0       0
#      3       0       0       0       0       0
#      4       0       0       0       0       0
# 
# 
# --------------- 3. Load and Material ---------------
# 
# Material properties:
# 	Young's modulus [MPa]: 206000
# 	Nominal yield strength of beams [MPa]: 248
# 	Nominal yield strength of columns [MPa]: 345
# 	Possion ratio: 0.3
# 
# Load [MPa]:
# Story/Floor         Dead         Live     Cladding
#         1/2 1.000000e-09 1.000000e-09 1.000000e-09
#         2/3 1.000000e-09 1.000000e-09 1.000000e-09
#         3/4 1.000000e-09 1.000000e-09 1.000000e-09
# 
# Load and mass combination coefficients:
#         Dead  Live  Cladding
# Weight  1.05  0.25      1.05
# Mass    1.00  0.00      1.00
# 
# Axial compressive ratio of columns:
# Story       Axis-1       Axis-2       Axis-3       Axis-4       Axis-5
#    1b 1.947412e-07 1.673158e-07 1.673158e-07 1.673158e-07 1.947412e-07
#    1t 1.947412e-07 1.673158e-07 1.673158e-07 1.673158e-07 1.947412e-07
#    2b 1.296480e-07 1.112470e-07 1.112470e-07 1.112470e-07 1.296480e-07
#    2t 1.296480e-07 1.112470e-07 1.112470e-07 1.112470e-07 1.296480e-07
#    3b 6.455484e-08 5.517823e-08 5.517823e-08 5.517823e-08 6.455484e-08
#    3t 6.455484e-08 5.517823e-08 5.517823e-08 5.517823e-08 6.455484e-08
# 
# Seiemic weight of considered 2D frame: 14780.00 kN
# Seiemic mass of considered 2D frame: 1478.00 t
# 
# 
# --------------- 4. Connection and Boundary Condition ---------------
# 
# Base support: Fixed
# Beam-to-column connection: Fully constrained connection
# Consider panel zone deformation: Yes (Parallelogram)
# 

