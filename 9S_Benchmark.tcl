# --------------------------------------------------------------------------------
# --------------------------------- 9S_Benchmark ---------------------------------
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
source Spring_PZ.tcl;
source Spring_IMK.tcl;
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
set NStory 10;
set NBay 5;
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
set Floor2 3650.0;
set Floor3 9140.0;
set Floor4 13100.0;
set Floor5 17060.0;
set Floor6 21020.0;
set Floor7 24980.0;
set Floor8 28940.0;
set Floor9 32900.0;
set Floor10 36860.0;
set Floor11 40820.0;

set Axis1 0.0;
set Axis2 9150.0;
set Axis3 18300.0;
set Axis4 27450.0;
set Axis5 36600.0;
set Axis6 45750.0;
set Axis7 54900.0;

set HBuilding 40820.0;
variable HBuilding 40820.0;


# ------------------------------------ Nodes -------------------------------------

# Support nodes
node 10010100 $Axis1 $Floor1;
node 10010200 $Axis2 $Floor1;
node 10010300 $Axis3 $Floor1;
node 10010400 $Axis4 $Floor1;
node 10010500 $Axis5 $Floor1;
node 10010600 $Axis6 $Floor1;
node 10010700 $Axis7 $Floor1;

# Leaning column grid nodes
node 10020700 $Axis7 $Floor2;
node 10030700 $Axis7 $Floor3;
node 10040700 $Axis7 $Floor4;
node 10050700 $Axis7 $Floor5;
node 10060700 $Axis7 $Floor6;
node 10070700 $Axis7 $Floor7;
node 10080700 $Axis7 $Floor8;
node 10090700 $Axis7 $Floor9;
node 10100700 $Axis7 $Floor10;
node 10110700 $Axis7 $Floor11;

# Leaning column connected nodes
node 10020702 $Axis7 $Floor2;
node 10020701 $Axis7 $Floor2;
node 10030702 $Axis7 $Floor3;
node 10030701 $Axis7 $Floor3;
node 10040702 $Axis7 $Floor4;
node 10040701 $Axis7 $Floor4;
node 10050702 $Axis7 $Floor5;
node 10050701 $Axis7 $Floor5;
node 10060702 $Axis7 $Floor6;
node 10060701 $Axis7 $Floor6;
node 10070702 $Axis7 $Floor7;
node 10070701 $Axis7 $Floor7;
node 10080702 $Axis7 $Floor8;
node 10080701 $Axis7 $Floor8;
node 10090702 $Axis7 $Floor9;
node 10090701 $Axis7 $Floor9;
node 10100702 $Axis7 $Floor10;
node 10100701 $Axis7 $Floor10;
node 10110702 $Axis7 $Floor11;

# Moment frame column nodes
node 10010101 $Axis1 $Floor1;  node 10010201 $Axis2 $Floor1;  node 10010301 $Axis3 $Floor1;  node 10010401 $Axis4 $Floor1;  node 10010501 $Axis5 $Floor1;  node 10010601 $Axis6 $Floor1;
node 10020102 $Axis1 [expr $Floor2 - 914.40/2];  node 10020202 $Axis2 [expr $Floor2 - 914.40/2];  node 10020302 $Axis3 [expr $Floor2 - 914.40/2];  node 10020402 $Axis4 [expr $Floor2 - 914.40/2];  node 10020502 $Axis5 [expr $Floor2 - 914.40/2];  node 10020602 $Axis6 [expr $Floor2 - 914.40/2];
node 10020101 $Axis1 [expr $Floor2 + 914.40/2];  node 10020201 $Axis2 [expr $Floor2 + 914.40/2];  node 10020301 $Axis3 [expr $Floor2 + 914.40/2];  node 10020401 $Axis4 [expr $Floor2 + 914.40/2];  node 10020501 $Axis5 [expr $Floor2 + 914.40/2];  node 10020601 $Axis6 [expr $Floor2 + 914.40/2];
node 10030102 $Axis1 [expr $Floor3 - 914.40/2];  node 10030202 $Axis2 [expr $Floor3 - 914.40/2];  node 10030302 $Axis3 [expr $Floor3 - 914.40/2];  node 10030402 $Axis4 [expr $Floor3 - 914.40/2];  node 10030502 $Axis5 [expr $Floor3 - 914.40/2];  node 10030602 $Axis6 [expr $Floor3 - 914.40/2];
node 10030101 $Axis1 [expr $Floor3 + 914.40/2];  node 10030201 $Axis2 [expr $Floor3 + 914.40/2];  node 10030301 $Axis3 [expr $Floor3 + 914.40/2];  node 10030401 $Axis4 [expr $Floor3 + 914.40/2];  node 10030501 $Axis5 [expr $Floor3 + 914.40/2];  node 10030601 $Axis6 [expr $Floor3 + 914.40/2];
node 10040102 $Axis1 [expr $Floor4 - 914.40/2];  node 10040202 $Axis2 [expr $Floor4 - 914.40/2];  node 10040302 $Axis3 [expr $Floor4 - 914.40/2];  node 10040402 $Axis4 [expr $Floor4 - 914.40/2];  node 10040502 $Axis5 [expr $Floor4 - 914.40/2];  node 10040602 $Axis6 [expr $Floor4 - 914.40/2];
node 10040101 $Axis1 [expr $Floor4 + 914.40/2];  node 10040201 $Axis2 [expr $Floor4 + 914.40/2];  node 10040301 $Axis3 [expr $Floor4 + 914.40/2];  node 10040401 $Axis4 [expr $Floor4 + 914.40/2];  node 10040501 $Axis5 [expr $Floor4 + 914.40/2];  node 10040601 $Axis6 [expr $Floor4 + 914.40/2];
node 10050102 $Axis1 [expr $Floor5 - 904.24/2];  node 10050202 $Axis2 [expr $Floor5 - 904.24/2];  node 10050302 $Axis3 [expr $Floor5 - 904.24/2];  node 10050402 $Axis4 [expr $Floor5 - 904.24/2];  node 10050502 $Axis5 [expr $Floor5 - 904.24/2];  node 10050602 $Axis6 [expr $Floor5 - 904.24/2];
node 10050101 $Axis1 [expr $Floor5 + 904.24/2];  node 10050201 $Axis2 [expr $Floor5 + 904.24/2];  node 10050301 $Axis3 [expr $Floor5 + 904.24/2];  node 10050401 $Axis4 [expr $Floor5 + 904.24/2];  node 10050501 $Axis5 [expr $Floor5 + 904.24/2];  node 10050601 $Axis6 [expr $Floor5 + 904.24/2];
node 10060102 $Axis1 [expr $Floor6 - 904.24/2];  node 10060202 $Axis2 [expr $Floor6 - 904.24/2];  node 10060302 $Axis3 [expr $Floor6 - 904.24/2];  node 10060402 $Axis4 [expr $Floor6 - 904.24/2];  node 10060502 $Axis5 [expr $Floor6 - 904.24/2];  node 10060602 $Axis6 [expr $Floor6 - 904.24/2];
node 10060101 $Axis1 [expr $Floor6 + 904.24/2];  node 10060201 $Axis2 [expr $Floor6 + 904.24/2];  node 10060301 $Axis3 [expr $Floor6 + 904.24/2];  node 10060401 $Axis4 [expr $Floor6 + 904.24/2];  node 10060501 $Axis5 [expr $Floor6 + 904.24/2];  node 10060601 $Axis6 [expr $Floor6 + 904.24/2];
node 10070102 $Axis1 [expr $Floor7 - 904.24/2];  node 10070202 $Axis2 [expr $Floor7 - 904.24/2];  node 10070302 $Axis3 [expr $Floor7 - 904.24/2];  node 10070402 $Axis4 [expr $Floor7 - 904.24/2];  node 10070502 $Axis5 [expr $Floor7 - 904.24/2];  node 10070602 $Axis6 [expr $Floor7 - 904.24/2];
node 10070101 $Axis1 [expr $Floor7 + 904.24/2];  node 10070201 $Axis2 [expr $Floor7 + 904.24/2];  node 10070301 $Axis3 [expr $Floor7 + 904.24/2];  node 10070401 $Axis4 [expr $Floor7 + 904.24/2];  node 10070501 $Axis5 [expr $Floor7 + 904.24/2];  node 10070601 $Axis6 [expr $Floor7 + 904.24/2];
node 10080102 $Axis1 [expr $Floor8 - 904.24/2];  node 10080202 $Axis2 [expr $Floor8 - 904.24/2];  node 10080302 $Axis3 [expr $Floor8 - 904.24/2];  node 10080402 $Axis4 [expr $Floor8 - 904.24/2];  node 10080502 $Axis5 [expr $Floor8 - 904.24/2];  node 10080602 $Axis6 [expr $Floor8 - 904.24/2];
node 10080101 $Axis1 [expr $Floor8 + 904.24/2];  node 10080201 $Axis2 [expr $Floor8 + 904.24/2];  node 10080301 $Axis3 [expr $Floor8 + 904.24/2];  node 10080401 $Axis4 [expr $Floor8 + 904.24/2];  node 10080501 $Axis5 [expr $Floor8 + 904.24/2];  node 10080601 $Axis6 [expr $Floor8 + 904.24/2];
node 10090102 $Axis1 [expr $Floor9 - 754.38/2];  node 10090202 $Axis2 [expr $Floor9 - 754.38/2];  node 10090302 $Axis3 [expr $Floor9 - 754.38/2];  node 10090402 $Axis4 [expr $Floor9 - 754.38/2];  node 10090502 $Axis5 [expr $Floor9 - 754.38/2];  node 10090602 $Axis6 [expr $Floor9 - 754.38/2];
node 10090101 $Axis1 [expr $Floor9 + 754.38/2];  node 10090201 $Axis2 [expr $Floor9 + 754.38/2];  node 10090301 $Axis3 [expr $Floor9 + 754.38/2];  node 10090401 $Axis4 [expr $Floor9 + 754.38/2];  node 10090501 $Axis5 [expr $Floor9 + 754.38/2];  node 10090601 $Axis6 [expr $Floor9 + 754.38/2];
node 10100102 $Axis1 [expr $Floor10 - 678.18/2];  node 10100202 $Axis2 [expr $Floor10 - 678.18/2];  node 10100302 $Axis3 [expr $Floor10 - 678.18/2];  node 10100402 $Axis4 [expr $Floor10 - 678.18/2];  node 10100502 $Axis5 [expr $Floor10 - 678.18/2];  node 10100602 $Axis6 [expr $Floor10 - 678.18/2];
node 10100101 $Axis1 [expr $Floor10 + 678.18/2];  node 10100201 $Axis2 [expr $Floor10 + 678.18/2];  node 10100301 $Axis3 [expr $Floor10 + 678.18/2];  node 10100401 $Axis4 [expr $Floor10 + 678.18/2];  node 10100501 $Axis5 [expr $Floor10 + 678.18/2];  node 10100601 $Axis6 [expr $Floor10 + 678.18/2];
node 10110102 $Axis1 [expr $Floor11 - 601.98/2];  node 10110202 $Axis2 [expr $Floor11 - 601.98/2];  node 10110302 $Axis3 [expr $Floor11 - 601.98/2];  node 10110402 $Axis4 [expr $Floor11 - 601.98/2];  node 10110502 $Axis5 [expr $Floor11 - 601.98/2];  node 10110602 $Axis6 [expr $Floor11 - 601.98/2];

# Moment frame beam nodes
node 10020104 [expr $Axis1 + 248.92] $Floor2;  node 10020205 [expr $Axis2 - 248.92] $Floor2;  node 10020204 [expr $Axis2 + 248.92] $Floor2;  node 10020305 [expr $Axis3 - 248.92] $Floor2;  node 10020304 [expr $Axis3 + 248.92] $Floor2;  node 10020405 [expr $Axis4 - 248.92] $Floor2;  node 10020404 [expr $Axis4 + 248.92] $Floor2;  node 10020505 [expr $Axis5 - 248.92] $Floor2;  node 10020504 [expr $Axis5 + 248.92] $Floor2;  node 10020605 [expr $Axis6 - 248.92] $Floor2;
node 10030104 [expr $Axis1 + 248.92] $Floor3;  node 10030205 [expr $Axis2 - 248.92] $Floor3;  node 10030204 [expr $Axis2 + 248.92] $Floor3;  node 10030305 [expr $Axis3 - 248.92] $Floor3;  node 10030304 [expr $Axis3 + 248.92] $Floor3;  node 10030405 [expr $Axis4 - 248.92] $Floor3;  node 10030404 [expr $Axis4 + 248.92] $Floor3;  node 10030505 [expr $Axis5 - 248.92] $Floor3;  node 10030504 [expr $Axis5 + 248.92] $Floor3;  node 10030605 [expr $Axis6 - 248.92] $Floor3;
node 10040104 [expr $Axis1 + 241.30] $Floor4;  node 10040205 [expr $Axis2 - 241.30] $Floor4;  node 10040204 [expr $Axis2 + 241.30] $Floor4;  node 10040305 [expr $Axis3 - 241.30] $Floor4;  node 10040304 [expr $Axis3 + 241.30] $Floor4;  node 10040405 [expr $Axis4 - 241.30] $Floor4;  node 10040404 [expr $Axis4 + 241.30] $Floor4;  node 10040505 [expr $Axis5 - 241.30] $Floor4;  node 10040504 [expr $Axis5 + 241.30] $Floor4;  node 10040605 [expr $Axis6 - 241.30] $Floor4;
node 10050104 [expr $Axis1 + 241.30] $Floor5;  node 10050205 [expr $Axis2 - 241.30] $Floor5;  node 10050204 [expr $Axis2 + 241.30] $Floor5;  node 10050305 [expr $Axis3 - 241.30] $Floor5;  node 10050304 [expr $Axis3 + 241.30] $Floor5;  node 10050405 [expr $Axis4 - 241.30] $Floor5;  node 10050404 [expr $Axis4 + 241.30] $Floor5;  node 10050505 [expr $Axis5 - 241.30] $Floor5;  node 10050504 [expr $Axis5 + 241.30] $Floor5;  node 10050605 [expr $Axis6 - 241.30] $Floor5;
node 10060104 [expr $Axis1 + 227.33] $Floor6;  node 10060205 [expr $Axis2 - 227.33] $Floor6;  node 10060204 [expr $Axis2 + 227.33] $Floor6;  node 10060305 [expr $Axis3 - 227.33] $Floor6;  node 10060304 [expr $Axis3 + 227.33] $Floor6;  node 10060405 [expr $Axis4 - 227.33] $Floor6;  node 10060404 [expr $Axis4 + 227.33] $Floor6;  node 10060505 [expr $Axis5 - 227.33] $Floor6;  node 10060504 [expr $Axis5 + 227.33] $Floor6;  node 10060605 [expr $Axis6 - 227.33] $Floor6;
node 10070104 [expr $Axis1 + 227.33] $Floor7;  node 10070205 [expr $Axis2 - 227.33] $Floor7;  node 10070204 [expr $Axis2 + 227.33] $Floor7;  node 10070305 [expr $Axis3 - 227.33] $Floor7;  node 10070304 [expr $Axis3 + 227.33] $Floor7;  node 10070405 [expr $Axis4 - 227.33] $Floor7;  node 10070404 [expr $Axis4 + 227.33] $Floor7;  node 10070505 [expr $Axis5 - 227.33] $Floor7;  node 10070504 [expr $Axis5 + 227.33] $Floor7;  node 10070605 [expr $Axis6 - 227.33] $Floor7;
node 10080104 [expr $Axis1 + 212.09] $Floor8;  node 10080205 [expr $Axis2 - 212.09] $Floor8;  node 10080204 [expr $Axis2 + 212.09] $Floor8;  node 10080305 [expr $Axis3 - 212.09] $Floor8;  node 10080304 [expr $Axis3 + 212.09] $Floor8;  node 10080405 [expr $Axis4 - 212.09] $Floor8;  node 10080404 [expr $Axis4 + 212.09] $Floor8;  node 10080505 [expr $Axis5 - 212.09] $Floor8;  node 10080504 [expr $Axis5 + 212.09] $Floor8;  node 10080605 [expr $Axis6 - 212.09] $Floor8;
node 10090104 [expr $Axis1 + 212.09] $Floor9;  node 10090205 [expr $Axis2 - 212.09] $Floor9;  node 10090204 [expr $Axis2 + 212.09] $Floor9;  node 10090305 [expr $Axis3 - 212.09] $Floor9;  node 10090304 [expr $Axis3 + 212.09] $Floor9;  node 10090405 [expr $Axis4 - 212.09] $Floor9;  node 10090404 [expr $Axis4 + 212.09] $Floor9;  node 10090505 [expr $Axis5 - 212.09] $Floor9;  node 10090504 [expr $Axis5 + 212.09] $Floor9;  node 10090605 [expr $Axis6 - 212.09] $Floor9;
node 10100104 [expr $Axis1 + 208.28] $Floor10;  node 10100205 [expr $Axis2 - 208.28] $Floor10;  node 10100204 [expr $Axis2 + 208.28] $Floor10;  node 10100305 [expr $Axis3 - 208.28] $Floor10;  node 10100304 [expr $Axis3 + 208.28] $Floor10;  node 10100405 [expr $Axis4 - 208.28] $Floor10;  node 10100404 [expr $Axis4 + 208.28] $Floor10;  node 10100505 [expr $Axis5 - 208.28] $Floor10;  node 10100504 [expr $Axis5 + 208.28] $Floor10;  node 10100605 [expr $Axis6 - 208.28] $Floor10;
node 10110104 [expr $Axis1 + 208.28] $Floor11;  node 10110205 [expr $Axis2 - 208.28] $Floor11;  node 10110204 [expr $Axis2 + 208.28] $Floor11;  node 10110305 [expr $Axis3 - 208.28] $Floor11;  node 10110304 [expr $Axis3 + 208.28] $Floor11;  node 10110405 [expr $Axis4 - 208.28] $Floor11;  node 10110404 [expr $Axis4 + 208.28] $Floor11;  node 10110505 [expr $Axis5 - 208.28] $Floor11;  node 10110504 [expr $Axis5 + 208.28] $Floor11;  node 10110605 [expr $Axis6 - 208.28] $Floor11;

# Beam spring nodes (If RBS length equal zero, beam spring nodes will not be generated)











# Column splice ndoes
node 10030107 $Axis1 [expr $Floor3 + 0.5 * 3960.00];  node 10030207 $Axis2 [expr $Floor3 + 0.5 * 3960.00];  node 10030307 $Axis3 [expr $Floor3 + 0.5 * 3960.00];  node 10030407 $Axis4 [expr $Floor3 + 0.5 * 3960.00];  node 10030507 $Axis5 [expr $Floor3 + 0.5 * 3960.00];  node 10030607 $Axis6 [expr $Floor3 + 0.5 * 3960.00];
node 10050107 $Axis1 [expr $Floor5 + 0.5 * 3960.00];  node 10050207 $Axis2 [expr $Floor5 + 0.5 * 3960.00];  node 10050307 $Axis3 [expr $Floor5 + 0.5 * 3960.00];  node 10050407 $Axis4 [expr $Floor5 + 0.5 * 3960.00];  node 10050507 $Axis5 [expr $Floor5 + 0.5 * 3960.00];  node 10050607 $Axis6 [expr $Floor5 + 0.5 * 3960.00];
node 10070107 $Axis1 [expr $Floor7 + 0.5 * 3960.00];  node 10070207 $Axis2 [expr $Floor7 + 0.5 * 3960.00];  node 10070307 $Axis3 [expr $Floor7 + 0.5 * 3960.00];  node 10070407 $Axis4 [expr $Floor7 + 0.5 * 3960.00];  node 10070507 $Axis5 [expr $Floor7 + 0.5 * 3960.00];  node 10070607 $Axis6 [expr $Floor7 + 0.5 * 3960.00];
node 10090107 $Axis1 [expr $Floor9 + 0.5 * 3960.00];  node 10090207 $Axis2 [expr $Floor9 + 0.5 * 3960.00];  node 10090307 $Axis3 [expr $Floor9 + 0.5 * 3960.00];  node 10090407 $Axis4 [expr $Floor9 + 0.5 * 3960.00];  node 10090507 $Axis5 [expr $Floor9 + 0.5 * 3960.00];  node 10090607 $Axis6 [expr $Floor9 + 0.5 * 3960.00];

# Beam splice ndoes












# ----------------------------------- Elements -----------------------------------

set n 10.;

# Column elements
element elasticBeamColumn 10010101 10010101 10020102 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10010201 10010201 10020202 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10010301 10010301 10020302 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10010401 10010401 10020402 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10010501 10010501 10020502 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10010601 10010601 10020602 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;
element elasticBeamColumn 10020101 10020101 10030102 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10020201 10020201 10030202 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10020301 10020301 10030302 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10020401 10020401 10030402 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10020501 10020501 10030502 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;  element elasticBeamColumn 10020601 10020601 10030602 94838.52 $E [expr ($n+1)/$n*3417260004.18] 2;
element elasticBeamColumn 10030102 10030101 10030107 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030202 10030201 10030207 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030302 10030301 10030307 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030402 10030401 10030407 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030502 10030501 10030507 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030602 10030601 10030607 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;
element elasticBeamColumn 10030103 10030107 10040102 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030203 10030207 10040202 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030303 10030307 10040302 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030403 10030407 10040402 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030503 10030507 10040502 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10030603 10030607 10040602 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;
element elasticBeamColumn 10040101 10040101 10050102 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10040201 10040201 10050202 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10040301 10040301 10050302 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10040401 10040401 10050402 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10040501 10040501 10050502 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;  element elasticBeamColumn 10040601 10040601 10050602 86451.44 $E [expr ($n+1)/$n*2992703950.06] 2;
element elasticBeamColumn 10050102 10050101 10050107 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050202 10050201 10050207 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050302 10050301 10050307 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050402 10050401 10050407 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050502 10050501 10050507 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050602 10050601 10050607 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;
element elasticBeamColumn 10050103 10050107 10060102 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050203 10050207 10060202 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050303 10050307 10060302 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050403 10050407 10060402 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050503 10050507 10060502 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10050603 10050607 10060602 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;
element elasticBeamColumn 10060101 10060101 10070102 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10060201 10060201 10070202 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10060301 10060301 10070302 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10060401 10060401 10070402 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10060501 10060501 10070502 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;  element elasticBeamColumn 10060601 10060601 10070602 70322.44 $E [expr ($n+1)/$n*2264298955.26] 2;
element elasticBeamColumn 10070102 10070101 10070107 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070202 10070201 10070207 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070302 10070301 10070307 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070402 10070401 10070407 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070502 10070501 10070507 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070602 10070601 10070607 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;
element elasticBeamColumn 10070103 10070107 10080102 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070203 10070207 10080202 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070303 10070307 10080302 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070403 10070407 10080402 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070503 10070507 10080502 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10070603 10070607 10080602 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;
element elasticBeamColumn 10080101 10080101 10090102 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10080201 10080201 10090202 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10080301 10080301 10090302 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10080401 10080401 10090402 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10080501 10080501 10090502 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;  element elasticBeamColumn 10080601 10080601 10090602 53741.83 $E [expr ($n+1)/$n*1598328674.30] 2;
element elasticBeamColumn 10090102 10090101 10090107 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090202 10090201 10090207 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090302 10090301 10090307 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090402 10090401 10090407 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090502 10090501 10090507 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090602 10090601 10090607 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;
element elasticBeamColumn 10090103 10090107 10100102 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090203 10090207 10100202 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090303 10090307 10100302 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090403 10090407 10100402 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090503 10090507 10100502 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10090603 10090607 10100602 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;
element elasticBeamColumn 10100101 10100101 10110102 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10100201 10100201 10110202 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10100301 10100301 10110302 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10100401 10100401 10110402 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10100501 10100501 10110502 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;  element elasticBeamColumn 10100601 10100601 10110602 48774.10 $E [expr ($n+1)/$n*1415186847.04] 2;

# Beam elements
element elasticBeamColumn 10020104 10020104 10020205 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10020204 10020204 10020305 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10020304 10020304 10020405 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10020404 10020404 10020505 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10020504 10020504 10020605 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;
element elasticBeamColumn 10030104 10030104 10030205 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10030204 10030204 10030305 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10030304 10030304 10030405 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10030404 10030404 10030505 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10030504 10030504 10030605 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;
element elasticBeamColumn 10040104 10040104 10040205 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10040204 10040204 10040305 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10040304 10040304 10040405 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10040404 10040404 10040505 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;  element elasticBeamColumn 10040504 10040504 10040605 30322.52 $E [expr ($n+1)/$n*4062418713.86] 2;
element elasticBeamColumn 10050104 10050104 10050205 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10050204 10050204 10050305 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10050304 10050304 10050405 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10050404 10050404 10050505 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10050504 10050504 10050605 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;
element elasticBeamColumn 10060104 10060104 10060205 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10060204 10060204 10060305 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10060304 10060304 10060405 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10060404 10060404 10060505 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10060504 10060504 10060605 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;
element elasticBeamColumn 10070104 10070104 10070205 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10070204 10070204 10070305 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10070304 10070304 10070405 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10070404 10070404 10070505 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10070504 10070504 10070605 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;
element elasticBeamColumn 10080104 10080104 10080205 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10080204 10080204 10080305 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10080304 10080304 10080405 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10080404 10080404 10080505 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;  element elasticBeamColumn 10080504 10080504 10080605 25741.88 $E [expr ($n+1)/$n*3246605119.68] 2;
element elasticBeamColumn 10090104 10090104 10090205 18709.64 $E [expr ($n+1)/$n*1660763388.14] 2;  element elasticBeamColumn 10090204 10090204 10090305 18709.64 $E [expr ($n+1)/$n*1660763388.14] 2;  element elasticBeamColumn 10090304 10090304 10090405 18709.64 $E [expr ($n+1)/$n*1660763388.14] 2;  element elasticBeamColumn 10090404 10090404 10090505 18709.64 $E [expr ($n+1)/$n*1660763388.14] 2;  element elasticBeamColumn 10090504 10090504 10090605 18709.64 $E [expr ($n+1)/$n*1660763388.14] 2;
element elasticBeamColumn 10100104 10100104 10100205 15935.45 $E [expr ($n+1)/$n*1186259562.96] 2;  element elasticBeamColumn 10100204 10100204 10100305 15935.45 $E [expr ($n+1)/$n*1186259562.96] 2;  element elasticBeamColumn 10100304 10100304 10100405 15935.45 $E [expr ($n+1)/$n*1186259562.96] 2;  element elasticBeamColumn 10100404 10100404 10100505 15935.45 $E [expr ($n+1)/$n*1186259562.96] 2;  element elasticBeamColumn 10100504 10100504 10100605 15935.45 $E [expr ($n+1)/$n*1186259562.96] 2;
element elasticBeamColumn 10110104 10110104 10110205 12967.72 $E [expr ($n+1)/$n*761703508.85] 2;  element elasticBeamColumn 10110204 10110204 10110305 12967.72 $E [expr ($n+1)/$n*761703508.85] 2;  element elasticBeamColumn 10110304 10110304 10110405 12967.72 $E [expr ($n+1)/$n*761703508.85] 2;  element elasticBeamColumn 10110404 10110404 10110505 12967.72 $E [expr ($n+1)/$n*761703508.85] 2;  element elasticBeamColumn 10110504 10110504 10110605 12967.72 $E [expr ($n+1)/$n*761703508.85] 2;

# Panel zones
# PanelNone Floor Axis X Y E mu fy_column A_stiff I_stiff d_col d_beam tp tf bf transfTag type_ position check ""
PanelZone 2 1 $Axis1 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "L";  PanelZone 2 2 $Axis2 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "I";  PanelZone 2 3 $Axis3 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "I";  PanelZone 2 4 $Axis4 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "I";  PanelZone 2 5 $Axis5 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "I";  PanelZone 2 6 $Axis6 $Floor2 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "R";
PanelZone 3 1 $Axis1 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "L";  PanelZone 3 2 $Axis2 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "I";  PanelZone 3 3 $Axis3 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "I";  PanelZone 3 4 $Axis4 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "I";  PanelZone 3 5 $Axis5 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "I";  PanelZone 3 6 $Axis6 $Floor3 $E $mu $fy_column $A_Stiff $I_Stiff 497.84 914.40 55.63 88.90 431.80 2 1 "R";
PanelZone 4 1 $Axis1 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 914.40 51.31 81.53 426.72 2 1 "L";  PanelZone 4 2 $Axis2 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 914.40 51.31 81.53 426.72 2 1 "I";  PanelZone 4 3 $Axis3 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 914.40 51.31 81.53 426.72 2 1 "I";  PanelZone 4 4 $Axis4 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 914.40 51.31 81.53 426.72 2 1 "I";  PanelZone 4 5 $Axis5 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 914.40 51.31 81.53 426.72 2 1 "I";  PanelZone 4 6 $Axis6 $Floor4 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 914.40 51.31 81.53 426.72 2 1 "R";
PanelZone 5 1 $Axis1 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 904.24 51.31 81.53 426.72 2 1 "L";  PanelZone 5 2 $Axis2 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 904.24 51.31 81.53 426.72 2 1 "I";  PanelZone 5 3 $Axis3 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 904.24 51.31 81.53 426.72 2 1 "I";  PanelZone 5 4 $Axis4 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 904.24 51.31 81.53 426.72 2 1 "I";  PanelZone 5 5 $Axis5 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 904.24 51.31 81.53 426.72 2 1 "I";  PanelZone 5 6 $Axis6 $Floor5 $E $mu $fy_column $A_Stiff $I_Stiff 482.60 904.24 51.31 81.53 426.72 2 1 "R";
PanelZone 6 1 $Axis1 $Floor6 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "L";  PanelZone 6 2 $Axis2 $Floor6 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "I";  PanelZone 6 3 $Axis3 $Floor6 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "I";  PanelZone 6 4 $Axis4 $Floor6 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "I";  PanelZone 6 5 $Axis5 $Floor6 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "I";  PanelZone 6 6 $Axis6 $Floor6 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "R";
PanelZone 7 1 $Axis1 $Floor7 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "L";  PanelZone 7 2 $Axis2 $Floor7 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "I";  PanelZone 7 3 $Axis3 $Floor7 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "I";  PanelZone 7 4 $Axis4 $Floor7 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "I";  PanelZone 7 5 $Axis5 $Floor7 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "I";  PanelZone 7 6 $Axis6 $Floor7 $E $mu $fy_column $A_Stiff $I_Stiff 454.66 904.24 42.16 67.56 419.10 2 1 "R";
PanelZone 8 1 $Axis1 $Floor8 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 904.24 32.77 52.58 408.94 2 1 "L";  PanelZone 8 2 $Axis2 $Floor8 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 904.24 32.77 52.58 408.94 2 1 "I";  PanelZone 8 3 $Axis3 $Floor8 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 904.24 32.77 52.58 408.94 2 1 "I";  PanelZone 8 4 $Axis4 $Floor8 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 904.24 32.77 52.58 408.94 2 1 "I";  PanelZone 8 5 $Axis5 $Floor8 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 904.24 32.77 52.58 408.94 2 1 "I";  PanelZone 8 6 $Axis6 $Floor8 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 904.24 32.77 52.58 408.94 2 1 "R";
PanelZone 9 1 $Axis1 $Floor9 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 754.38 32.77 52.58 408.94 2 1 "L";  PanelZone 9 2 $Axis2 $Floor9 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 754.38 32.77 52.58 408.94 2 1 "I";  PanelZone 9 3 $Axis3 $Floor9 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 754.38 32.77 52.58 408.94 2 1 "I";  PanelZone 9 4 $Axis4 $Floor9 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 754.38 32.77 52.58 408.94 2 1 "I";  PanelZone 9 5 $Axis5 $Floor9 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 754.38 32.77 52.58 408.94 2 1 "I";  PanelZone 9 6 $Axis6 $Floor9 $E $mu $fy_column $A_Stiff $I_Stiff 424.18 754.38 32.77 52.58 408.94 2 1 "R";
PanelZone 10 1 $Axis1 $Floor10 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 678.18 29.97 48.01 406.40 2 1 "L";  PanelZone 10 2 $Axis2 $Floor10 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 678.18 29.97 48.01 406.40 2 1 "I";  PanelZone 10 3 $Axis3 $Floor10 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 678.18 29.97 48.01 406.40 2 1 "I";  PanelZone 10 4 $Axis4 $Floor10 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 678.18 29.97 48.01 406.40 2 1 "I";  PanelZone 10 5 $Axis5 $Floor10 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 678.18 29.97 48.01 406.40 2 1 "I";  PanelZone 10 6 $Axis6 $Floor10 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 678.18 29.97 48.01 406.40 2 1 "R";
PanelZone 11 1 $Axis1 $Floor11 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 601.98 29.97 48.01 406.40 2 1 "LT";  PanelZone 11 2 $Axis2 $Floor11 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 601.98 29.97 48.01 406.40 2 1 "T";  PanelZone 11 3 $Axis3 $Floor11 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 601.98 29.97 48.01 406.40 2 1 "T";  PanelZone 11 4 $Axis4 $Floor11 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 601.98 29.97 48.01 406.40 2 1 "T";  PanelZone 11 5 $Axis5 $Floor11 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 601.98 29.97 48.01 406.40 2 1 "T";  PanelZone 11 6 $Axis6 $Floor11 $E $mu $fy_column $A_Stiff $I_Stiff 416.56 601.98 29.97 48.01 406.40 2 1 "RT";

# RBS elements (If RBS length equal zero, RBS element will not be generated)











# Beam hinges
# BeamHinge SpringID NodeI NodeJ E fy_beam Ix d htw bftf ry L Ls Lb My type_ {check ""}
BeamHinge 10020109 11020104 10020104 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10020210 10020205 11020202 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10020209 11020204 10020204 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10020310 10020305 11020302 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10020309 11020304 10020304 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10020410 10020405 11020402 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10020409 11020404 10020404 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10020510 10020505 11020502 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10020509 11020504 10020504 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10020610 10020605 11020602 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;
BeamHinge 10030109 11030104 10030104 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10030210 10030205 11030202 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10030209 11030204 10030204 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10030310 10030305 11030302 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10030309 11030304 10030304 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10030410 10030405 11030402 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10030409 11030404 10030404 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10030510 10030505 11030502 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10030509 11030504 10030504 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;  BeamHinge 10030610 10030605 11030602 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8652.2 4326.1 4326.1 2535930928.13 2;
BeamHinge 10040109 11040104 10040104 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;  BeamHinge 10040210 10040205 11040202 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;  BeamHinge 10040209 11040204 10040204 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;  BeamHinge 10040310 10040305 11040302 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;  BeamHinge 10040309 11040304 10040304 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;  BeamHinge 10040410 10040405 11040402 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;  BeamHinge 10040409 11040404 10040404 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;  BeamHinge 10040510 10040505 11040502 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;  BeamHinge 10040509 11040504 10040504 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;  BeamHinge 10040610 10040605 11040602 $E $fy_beam 4062418713.86 914.40 49.94 5.88 63.63 8667.4 4333.7 4333.7 2535930928.13 2;
BeamHinge 10050109 11050104 10050104 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;  BeamHinge 10050210 10050205 11050202 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;  BeamHinge 10050209 11050204 10050204 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;  BeamHinge 10050310 10050305 11050302 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;  BeamHinge 10050309 11050304 10050304 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;  BeamHinge 10050410 10050405 11050402 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;  BeamHinge 10050409 11050404 10050404 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;  BeamHinge 10050510 10050505 11050502 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;  BeamHinge 10050509 11050504 10050504 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;  BeamHinge 10050610 10050605 11050602 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8667.4 4333.7 4333.7 2068571862.85 2;
BeamHinge 10060109 11060104 10060104 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10060210 10060205 11060202 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10060209 11060204 10060204 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10060310 10060305 11060302 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10060309 11060304 10060304 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10060410 10060405 11060402 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10060409 11060404 10060404 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10060510 10060505 11060502 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10060509 11060504 10060504 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10060610 10060605 11060602 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;
BeamHinge 10070109 11070104 10070104 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10070210 10070205 11070202 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10070209 11070204 10070204 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10070310 10070305 11070302 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10070309 11070304 10070304 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10070410 10070405 11070402 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10070409 11070404 10070404 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10070510 10070505 11070502 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10070509 11070504 10070504 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;  BeamHinge 10070610 10070605 11070602 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8695.3 4347.7 4347.7 2068571862.85 2;
BeamHinge 10080109 11080104 10080104 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;  BeamHinge 10080210 10080205 11080202 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;  BeamHinge 10080209 11080204 10080204 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;  BeamHinge 10080310 10080305 11080302 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;  BeamHinge 10080309 11080304 10080304 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;  BeamHinge 10080410 10080405 11080402 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;  BeamHinge 10080409 11080404 10080404 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;  BeamHinge 10080510 10080505 11080502 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;  BeamHinge 10080509 11080504 10080504 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;  BeamHinge 10080610 10080605 11080602 $E $fy_beam 3246605119.68 904.24 54.20 7.59 60.32 8725.8 4362.9 4362.9 2068571862.85 2;
BeamHinge 10090109 11090104 10090104 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;  BeamHinge 10090210 10090205 11090202 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;  BeamHinge 10090209 11090204 10090204 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;  BeamHinge 10090310 10090305 11090302 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;  BeamHinge 10090309 11090304 10090304 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;  BeamHinge 10090410 10090405 11090402 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;  BeamHinge 10090409 11090404 10090404 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;  BeamHinge 10090510 10090505 11090502 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;  BeamHinge 10090509 11090504 10090504 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;  BeamHinge 10090610 10090605 11090602 $E $fy_beam 1660763388.14 754.38 52.04 7.84 53.36 8725.8 4362.9 4362.9 1267965464.06 2;
BeamHinge 10100109 11100104 10100104 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;  BeamHinge 10100210 10100205 11100202 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;  BeamHinge 10100209 11100204 10100204 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;  BeamHinge 10100310 10100305 11100302 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;  BeamHinge 10100309 11100304 10100304 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;  BeamHinge 10100410 10100405 11100402 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;  BeamHinge 10100409 11100404 10100404 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;  BeamHinge 10100510 10100505 11100502 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;  BeamHinge 10100509 11100504 10100504 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;  BeamHinge 10100610 10100605 11100602 $E $fy_beam 1186259562.96 678.18 52.65 7.81 52.62 8733.4 4366.7 4366.7 991614016.77 2;
BeamHinge 10110109 11110104 10110104 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;  BeamHinge 10110210 10110205 11110202 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;  BeamHinge 10110209 11110204 10110204 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;  BeamHinge 10110310 10110305 11110302 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;  BeamHinge 10110309 11110304 10110304 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;  BeamHinge 10110410 10110405 11110402 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;  BeamHinge 10110409 11110404 10110404 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;  BeamHinge 10110510 10110505 11110502 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;  BeamHinge 10110509 11110504 10110504 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;  BeamHinge 10110610 10110605 11110602 $E $fy_beam 761703508.85 601.98 51.86 7.67 47.54 8733.4 4366.7 4366.7 719326561.34 2;

# Column hinges
# Column SpringID NodeI NodeJ E Ix d htw ry L Lb My PPy SF_PPy pinned check ""
ColumnHinge 10010107 10010100 10010101 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 2;  ColumnHinge 10010207 10010200 10010201 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 2;  ColumnHinge 10010307 10010300 10010301 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 2;  ColumnHinge 10010407 10010400 10010401 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 2;  ColumnHinge 10010507 10010500 10010501 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 2;  ColumnHinge 10010607 10010600 10010601 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 2;
ColumnHinge 10020108 10020102 11020101 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020208 10020202 11020201 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020308 10020302 11020301 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020408 10020402 11020401 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020508 10020502 11020501 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020608 10020602 11020601 $E 3417260004.18 497.84 5.21 112.43 3192.80 3192.80 5936213934.00 0.0000 1.25 1;
ColumnHinge 10020107 11020103 10020101 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020207 11020203 10020201 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020307 11020303 10020301 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020407 11020403 10020401 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020507 11020503 10020501 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10020607 11020603 10020601 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;
ColumnHinge 10030108 10030102 11030101 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10030208 10030202 11030201 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10030308 10030302 11030301 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10030408 10030402 11030401 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10030508 10030502 11030501 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;  ColumnHinge 10030608 10030602 11030601 $E 3417260004.18 497.84 5.21 112.43 4575.60 4575.60 5936213934.00 0.0000 1.25 1;
ColumnHinge 10030107 11030103 10030101 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10030207 11030203 10030201 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10030307 11030303 10030301 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10030407 11030403 10030401 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10030507 11030503 10030501 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10030607 11030603 10030601 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;
ColumnHinge 10040108 10040102 11040101 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040208 10040202 11040201 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040308 10040302 11040301 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040408 10040402 11040401 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040508 10040502 11040501 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040608 10040602 11040601 $E 2992703950.06 482.60 5.63 111.02 3045.60 3045.60 5291710706.88 0.0000 1.25 1;
ColumnHinge 10040107 11040103 10040101 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040207 11040203 10040201 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040307 11040303 10040301 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040407 11040403 10040401 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040507 11040503 10040501 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10040607 11040603 10040601 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;
ColumnHinge 10050108 10050102 11050101 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10050208 10050202 11050201 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10050308 10050302 11050301 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10050408 10050402 11050401 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10050508 10050502 11050501 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;  ColumnHinge 10050608 10050602 11050601 $E 2992703950.06 482.60 5.63 111.02 3050.68 3050.68 5291710706.88 0.0000 1.25 1;
ColumnHinge 10050107 11050103 10050101 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10050207 11050203 10050201 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10050307 11050303 10050301 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10050407 11050403 10050401 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10050507 11050503 10050501 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10050607 11050603 10050601 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;
ColumnHinge 10060108 10060102 11060101 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060208 10060202 11060201 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060308 10060302 11060301 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060408 10060402 11060401 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060508 10060502 11060501 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060608 10060602 11060601 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;
ColumnHinge 10060107 11060103 10060101 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060207 11060203 10060201 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060307 11060303 10060301 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060407 11060403 10060401 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060507 11060503 10060501 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10060607 11060603 10060601 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;
ColumnHinge 10070108 10070102 11070101 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10070208 10070202 11070201 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10070308 10070302 11070301 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10070408 10070402 11070401 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10070508 10070502 11070501 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;  ColumnHinge 10070608 10070602 11070601 $E 2264298955.26 454.66 6.86 108.53 3055.76 3055.76 4161003290.88 0.0000 1.25 1;
ColumnHinge 10070107 11070103 10070101 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10070207 11070203 10070201 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10070307 11070303 10070301 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10070407 11070403 10070401 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10070507 11070503 10070501 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10070607 11070603 10070601 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;
ColumnHinge 10080108 10080102 11080101 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080208 10080202 11080201 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080308 10080302 11080301 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080408 10080402 11080401 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080508 10080502 11080501 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080608 10080602 11080601 $E 1598328674.30 424.18 8.81 105.61 3055.76 3055.76 3064217097.36 0.0000 1.25 1;
ColumnHinge 10080107 11080103 10080101 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080207 11080203 10080201 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080307 11080303 10080301 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080407 11080403 10080401 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080507 11080503 10080501 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10080607 11080603 10080601 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;
ColumnHinge 10090108 10090102 11090101 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10090208 10090202 11090201 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10090308 10090302 11090301 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10090408 10090402 11090401 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10090508 10090502 11090501 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;  ColumnHinge 10090608 10090602 11090601 $E 1598328674.30 424.18 8.81 105.61 3130.69 3130.69 3064217097.36 0.0000 1.25 1;
ColumnHinge 10090107 11090103 10090101 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10090207 11090203 10090201 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10090307 11090303 10090301 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10090407 11090403 10090401 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10090507 11090503 10090501 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10090607 11090603 10090601 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;
ColumnHinge 10100108 10100102 11100101 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100208 10100202 11100201 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100308 10100302 11100301 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100408 10100402 11100401 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100508 10100502 11100501 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100608 10100602 11100601 $E 1415186847.04 416.56 9.68 104.92 3243.72 3243.72 2753272557.96 0.0000 1.25 1;
ColumnHinge 10100107 11100103 10100101 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100207 11100203 10100201 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100307 11100303 10100301 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100407 11100403 10100401 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100507 11100503 10100501 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10100607 11100603 10100601 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;
ColumnHinge 10110108 10110102 11110101 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10110208 10110202 11110201 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10110308 10110302 11110301 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10110408 10110402 11110401 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10110508 10110502 11110501 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;  ColumnHinge 10110608 10110602 11110601 $E 1415186847.04 416.56 9.68 104.92 3319.92 3319.92 2753272557.96 0.0000 1.25 1;

# Rigid links
element truss 10020604 11020604 10020700 $A_Stiff 99;
element truss 10030604 11030604 10030700 $A_Stiff 99;
element truss 10040604 11040604 10040700 $A_Stiff 99;
element truss 10050604 11050604 10050700 $A_Stiff 99;
element truss 10060604 11060604 10060700 $A_Stiff 99;
element truss 10070604 11070604 10070700 $A_Stiff 99;
element truss 10080604 11080604 10080700 $A_Stiff 99;
element truss 10090604 11090604 10090700 $A_Stiff 99;
element truss 10100604 11100604 10100700 $A_Stiff 99;
element truss 10110604 11110604 10110700 $A_Stiff 99;

# Leaning column
element elasticBeamColumn 10010701 10010700 10020702 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10020701 10020701 10030702 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10030701 10030701 10040702 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10040701 10040701 10050702 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10050701 10050701 10060702 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10060701 10060701 10070702 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10070701 10070701 10080702 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10080701 10080701 10090702 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10090701 10090701 10100702 $A_Stiff $E $I_Stiff 2;
element elasticBeamColumn 10100701 10100701 10110702 $A_Stiff $E $I_Stiff 2;

# Leaning column hinges
Spring_Rigid 10020708 10020702 10020700;
Spring_Zero 10020707 10020700 10020701;
Spring_Rigid 10030708 10030702 10030700;
Spring_Zero 10030707 10030700 10030701;
Spring_Rigid 10040708 10040702 10040700;
Spring_Zero 10040707 10040700 10040701;
Spring_Rigid 10050708 10050702 10050700;
Spring_Zero 10050707 10050700 10050701;
Spring_Rigid 10060708 10060702 10060700;
Spring_Zero 10060707 10060700 10060701;
Spring_Rigid 10070708 10070702 10070700;
Spring_Zero 10070707 10070700 10070701;
Spring_Rigid 10080708 10080702 10080700;
Spring_Zero 10080707 10080700 10080701;
Spring_Rigid 10090708 10090702 10090700;
Spring_Zero 10090707 10090700 10090701;
Spring_Rigid 10100708 10100702 10100700;
Spring_Zero 10100707 10100700 10100701;
Spring_Rigid 10110708 10110702 10110700;

# --------------------------------- Constraints ----------------------------------

# Support
fix 10010100 1 1 1;
fix 10010200 1 1 1;
fix 10010300 1 1 1;
fix 10010400 1 1 1;
fix 10010500 1 1 1;
fix 10010600 1 1 1;
fix 10010700 1 1 0;

# Soil constraint
# (No soil constraint)

# Rigid diaphragm
equalDOF 11020304 11020104 1;  equalDOF 11020304 11020204 1;  equalDOF 11020304 11020404 1;  equalDOF 11020304 11020504 1;  equalDOF 11020304 11020604 1;
equalDOF 11030304 11030104 1;  equalDOF 11030304 11030204 1;  equalDOF 11030304 11030404 1;  equalDOF 11030304 11030504 1;  equalDOF 11030304 11030604 1;
equalDOF 11040304 11040104 1;  equalDOF 11040304 11040204 1;  equalDOF 11040304 11040404 1;  equalDOF 11040304 11040504 1;  equalDOF 11040304 11040604 1;
equalDOF 11050304 11050104 1;  equalDOF 11050304 11050204 1;  equalDOF 11050304 11050404 1;  equalDOF 11050304 11050504 1;  equalDOF 11050304 11050604 1;
equalDOF 11060304 11060104 1;  equalDOF 11060304 11060204 1;  equalDOF 11060304 11060404 1;  equalDOF 11060304 11060504 1;  equalDOF 11060304 11060604 1;
equalDOF 11070304 11070104 1;  equalDOF 11070304 11070204 1;  equalDOF 11070304 11070404 1;  equalDOF 11070304 11070504 1;  equalDOF 11070304 11070604 1;
equalDOF 11080304 11080104 1;  equalDOF 11080304 11080204 1;  equalDOF 11080304 11080404 1;  equalDOF 11080304 11080504 1;  equalDOF 11080304 11080604 1;
equalDOF 11090304 11090104 1;  equalDOF 11090304 11090204 1;  equalDOF 11090304 11090404 1;  equalDOF 11090304 11090504 1;  equalDOF 11090304 11090604 1;
equalDOF 11100304 11100104 1;  equalDOF 11100304 11100204 1;  equalDOF 11100304 11100404 1;  equalDOF 11100304 11100504 1;  equalDOF 11100304 11100604 1;
equalDOF 11110304 11110104 1;  equalDOF 11110304 11110204 1;  equalDOF 11110304 11110404 1;  equalDOF 11110304 11110504 1;  equalDOF 11110304 11110604 1;

# ---------------------------------- Recorders -----------------------------------

# Mode properties
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode1.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 1";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode2.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 2";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode3.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 3";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode4.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 4";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode5.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 5";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode6.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 6";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode7.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 7";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode8.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 8";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode9.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 9";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode10.out -node 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304 -dof 1 "eigen 10";

# Time
recorder Node -file $MainFolder/$SubFolder/Time.out -time -node 10010100 -dof 1 disp;

# Support reactions
recorder Node -file $MainFolder/$SubFolder/Support1.out -node 10010100 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support2.out -node 10010200 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support3.out -node 10010300 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support4.out -node 10010400 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support5.out -node 10010500 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support6.out -node 10010600 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support7.out -node 10010700 -dof 1 2 3 reaction;

# Story drift ratio
recorder Drift -file $MainFolder/$SubFolder/SDR1_MF.out -iNode 10010100 -jNode 11020304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR2_MF.out -iNode 11020304 -jNode 11030304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR3_MF.out -iNode 11030304 -jNode 11040304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR4_MF.out -iNode 11040304 -jNode 11050304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR5_MF.out -iNode 11050304 -jNode 11060304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR6_MF.out -iNode 11060304 -jNode 11070304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR7_MF.out -iNode 11070304 -jNode 11080304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR8_MF.out -iNode 11080304 -jNode 11090304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR9_MF.out -iNode 11090304 -jNode 11100304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR10_MF.out -iNode 11100304 -jNode 11110304 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDRALL_MF.out -iNode 10010100 -jNode 11110304 -dof 1 -perpDirn 2;

# Floor acceleration
recorder Node -file $MainFolder/$SubFolder/RFA1_MF.out -node 10010100 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA2_MF.out -node 11020304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA3_MF.out -node 11030304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA4_MF.out -node 11040304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA5_MF.out -node 11050304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA6_MF.out -node 11060304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA7_MF.out -node 11070304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA8_MF.out -node 11080304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA9_MF.out -node 11090304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA10_MF.out -node 11100304 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA11_MF.out -node 11110304 -dof 1 accel;

# Floor velocity
recorder Node -file $MainFolder/$SubFolder/RFV1_MF.out -node 10010100 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV2_MF.out -node 11020304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV3_MF.out -node 11030304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV4_MF.out -node 11040304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV5_MF.out -node 11050304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV6_MF.out -node 11060304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV7_MF.out -node 11070304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV8_MF.out -node 11080304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV9_MF.out -node 11090304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV10_MF.out -node 11100304 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV11_MF.out -node 11110304 -dof 1 vel;

# Floor displacement
recorder Node -file $MainFolder/$SubFolder/Disp1_MF.out -node 10010100 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp2_MF.out -node 11020304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp3_MF.out -node 11030304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp4_MF.out -node 11040304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp5_MF.out -node 11050304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp6_MF.out -node 11060304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp7_MF.out -node 11070304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp8_MF.out -node 11080304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp9_MF.out -node 11090304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp10_MF.out -node 11100304 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp11_MF.out -node 11110304 -dof 1 disp;

# Column forces
recorder Element -file $MainFolder/$SubFolder/Column11.out -ele 10010101 force;  recorder Element -file $MainFolder/$SubFolder/Column12.out -ele 10010201 force;  recorder Element -file $MainFolder/$SubFolder/Column13.out -ele 10010301 force;  recorder Element -file $MainFolder/$SubFolder/Column14.out -ele 10010401 force;  recorder Element -file $MainFolder/$SubFolder/Column15.out -ele 10010501 force;  recorder Element -file $MainFolder/$SubFolder/Column16.out -ele 10010601 force;
recorder Element -file $MainFolder/$SubFolder/Column21.out -ele 10020101 force;  recorder Element -file $MainFolder/$SubFolder/Column22.out -ele 10020201 force;  recorder Element -file $MainFolder/$SubFolder/Column23.out -ele 10020301 force;  recorder Element -file $MainFolder/$SubFolder/Column24.out -ele 10020401 force;  recorder Element -file $MainFolder/$SubFolder/Column25.out -ele 10020501 force;  recorder Element -file $MainFolder/$SubFolder/Column26.out -ele 10020601 force;
recorder Element -file $MainFolder/$SubFolder/Column31.out -ele 10030102 force;  recorder Element -file $MainFolder/$SubFolder/Column32.out -ele 10030202 force;  recorder Element -file $MainFolder/$SubFolder/Column33.out -ele 10030302 force;  recorder Element -file $MainFolder/$SubFolder/Column34.out -ele 10030402 force;  recorder Element -file $MainFolder/$SubFolder/Column35.out -ele 10030502 force;  recorder Element -file $MainFolder/$SubFolder/Column36.out -ele 10030602 force;
recorder Element -file $MainFolder/$SubFolder/Column41.out -ele 10040101 force;  recorder Element -file $MainFolder/$SubFolder/Column42.out -ele 10040201 force;  recorder Element -file $MainFolder/$SubFolder/Column43.out -ele 10040301 force;  recorder Element -file $MainFolder/$SubFolder/Column44.out -ele 10040401 force;  recorder Element -file $MainFolder/$SubFolder/Column45.out -ele 10040501 force;  recorder Element -file $MainFolder/$SubFolder/Column46.out -ele 10040601 force;
recorder Element -file $MainFolder/$SubFolder/Column51.out -ele 10050102 force;  recorder Element -file $MainFolder/$SubFolder/Column52.out -ele 10050202 force;  recorder Element -file $MainFolder/$SubFolder/Column53.out -ele 10050302 force;  recorder Element -file $MainFolder/$SubFolder/Column54.out -ele 10050402 force;  recorder Element -file $MainFolder/$SubFolder/Column55.out -ele 10050502 force;  recorder Element -file $MainFolder/$SubFolder/Column56.out -ele 10050602 force;
recorder Element -file $MainFolder/$SubFolder/Column61.out -ele 10060101 force;  recorder Element -file $MainFolder/$SubFolder/Column62.out -ele 10060201 force;  recorder Element -file $MainFolder/$SubFolder/Column63.out -ele 10060301 force;  recorder Element -file $MainFolder/$SubFolder/Column64.out -ele 10060401 force;  recorder Element -file $MainFolder/$SubFolder/Column65.out -ele 10060501 force;  recorder Element -file $MainFolder/$SubFolder/Column66.out -ele 10060601 force;
recorder Element -file $MainFolder/$SubFolder/Column71.out -ele 10070102 force;  recorder Element -file $MainFolder/$SubFolder/Column72.out -ele 10070202 force;  recorder Element -file $MainFolder/$SubFolder/Column73.out -ele 10070302 force;  recorder Element -file $MainFolder/$SubFolder/Column74.out -ele 10070402 force;  recorder Element -file $MainFolder/$SubFolder/Column75.out -ele 10070502 force;  recorder Element -file $MainFolder/$SubFolder/Column76.out -ele 10070602 force;
recorder Element -file $MainFolder/$SubFolder/Column81.out -ele 10080101 force;  recorder Element -file $MainFolder/$SubFolder/Column82.out -ele 10080201 force;  recorder Element -file $MainFolder/$SubFolder/Column83.out -ele 10080301 force;  recorder Element -file $MainFolder/$SubFolder/Column84.out -ele 10080401 force;  recorder Element -file $MainFolder/$SubFolder/Column85.out -ele 10080501 force;  recorder Element -file $MainFolder/$SubFolder/Column86.out -ele 10080601 force;
recorder Element -file $MainFolder/$SubFolder/Column91.out -ele 10090102 force;  recorder Element -file $MainFolder/$SubFolder/Column92.out -ele 10090202 force;  recorder Element -file $MainFolder/$SubFolder/Column93.out -ele 10090302 force;  recorder Element -file $MainFolder/$SubFolder/Column94.out -ele 10090402 force;  recorder Element -file $MainFolder/$SubFolder/Column95.out -ele 10090502 force;  recorder Element -file $MainFolder/$SubFolder/Column96.out -ele 10090602 force;
recorder Element -file $MainFolder/$SubFolder/Column101.out -ele 10100101 force;  recorder Element -file $MainFolder/$SubFolder/Column102.out -ele 10100201 force;  recorder Element -file $MainFolder/$SubFolder/Column103.out -ele 10100301 force;  recorder Element -file $MainFolder/$SubFolder/Column104.out -ele 10100401 force;  recorder Element -file $MainFolder/$SubFolder/Column105.out -ele 10100501 force;  recorder Element -file $MainFolder/$SubFolder/Column106.out -ele 10100601 force;

# Column springs forces
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_F.out -ele 10010107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring12T_F.out -ele 10010207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring13T_F.out -ele 10010307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring14T_F.out -ele 10010407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring15T_F.out -ele 10010507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring16T_F.out -ele 10010607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_F.out -ele 10020108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring22B_F.out -ele 10020208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring23B_F.out -ele 10020308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring24B_F.out -ele 10020408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring25B_F.out -ele 10020508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring26B_F.out -ele 10020608 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_F.out -ele 10020107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring22T_F.out -ele 10020207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring23T_F.out -ele 10020307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring24T_F.out -ele 10020407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring25T_F.out -ele 10020507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring26T_F.out -ele 10020607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_F.out -ele 10030108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring32B_F.out -ele 10030208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring33B_F.out -ele 10030308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring34B_F.out -ele 10030408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring35B_F.out -ele 10030508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring36B_F.out -ele 10030608 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_F.out -ele 10030107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring32T_F.out -ele 10030207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring33T_F.out -ele 10030307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring34T_F.out -ele 10030407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring35T_F.out -ele 10030507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring36T_F.out -ele 10030607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_F.out -ele 10040108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring42B_F.out -ele 10040208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring43B_F.out -ele 10040308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring44B_F.out -ele 10040408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring45B_F.out -ele 10040508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring46B_F.out -ele 10040608 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring41T_F.out -ele 10040107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring42T_F.out -ele 10040207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring43T_F.out -ele 10040307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring44T_F.out -ele 10040407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring45T_F.out -ele 10040507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring46T_F.out -ele 10040607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring51B_F.out -ele 10050108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring52B_F.out -ele 10050208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring53B_F.out -ele 10050308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring54B_F.out -ele 10050408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring55B_F.out -ele 10050508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring56B_F.out -ele 10050608 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring51T_F.out -ele 10050107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring52T_F.out -ele 10050207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring53T_F.out -ele 10050307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring54T_F.out -ele 10050407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring55T_F.out -ele 10050507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring56T_F.out -ele 10050607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring61B_F.out -ele 10060108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring62B_F.out -ele 10060208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring63B_F.out -ele 10060308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring64B_F.out -ele 10060408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring65B_F.out -ele 10060508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring66B_F.out -ele 10060608 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring61T_F.out -ele 10060107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring62T_F.out -ele 10060207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring63T_F.out -ele 10060307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring64T_F.out -ele 10060407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring65T_F.out -ele 10060507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring66T_F.out -ele 10060607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring71B_F.out -ele 10070108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring72B_F.out -ele 10070208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring73B_F.out -ele 10070308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring74B_F.out -ele 10070408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring75B_F.out -ele 10070508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring76B_F.out -ele 10070608 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring71T_F.out -ele 10070107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring72T_F.out -ele 10070207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring73T_F.out -ele 10070307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring74T_F.out -ele 10070407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring75T_F.out -ele 10070507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring76T_F.out -ele 10070607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring81B_F.out -ele 10080108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring82B_F.out -ele 10080208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring83B_F.out -ele 10080308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring84B_F.out -ele 10080408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring85B_F.out -ele 10080508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring86B_F.out -ele 10080608 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring81T_F.out -ele 10080107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring82T_F.out -ele 10080207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring83T_F.out -ele 10080307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring84T_F.out -ele 10080407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring85T_F.out -ele 10080507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring86T_F.out -ele 10080607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring91B_F.out -ele 10090108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring92B_F.out -ele 10090208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring93B_F.out -ele 10090308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring94B_F.out -ele 10090408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring95B_F.out -ele 10090508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring96B_F.out -ele 10090608 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring91T_F.out -ele 10090107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring92T_F.out -ele 10090207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring93T_F.out -ele 10090307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring94T_F.out -ele 10090407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring95T_F.out -ele 10090507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring96T_F.out -ele 10090607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring101B_F.out -ele 10100108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring102B_F.out -ele 10100208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring103B_F.out -ele 10100308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring104B_F.out -ele 10100408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring105B_F.out -ele 10100508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring106B_F.out -ele 10100608 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring101T_F.out -ele 10100107 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring102T_F.out -ele 10100207 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring103T_F.out -ele 10100307 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring104T_F.out -ele 10100407 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring105T_F.out -ele 10100507 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring106T_F.out -ele 10100607 force;
recorder Element -file $MainFolder/$SubFolder/ColSpring111B_F.out -ele 10110108 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring112B_F.out -ele 10110208 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring113B_F.out -ele 10110308 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring114B_F.out -ele 10110408 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring115B_F.out -ele 10110508 force;  recorder Element -file $MainFolder/$SubFolder/ColSpring116B_F.out -ele 10110608 force;

# Column springs rotations
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_D.out -ele 10010107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring12T_D.out -ele 10010207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring13T_D.out -ele 10010307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring14T_D.out -ele 10010407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring15T_D.out -ele 10010507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring16T_D.out -ele 10010607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_D.out -ele 10020108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring22B_D.out -ele 10020208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring23B_D.out -ele 10020308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring24B_D.out -ele 10020408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring25B_D.out -ele 10020508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring26B_D.out -ele 10020608 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_D.out -ele 10020107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring22T_D.out -ele 10020207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring23T_D.out -ele 10020307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring24T_D.out -ele 10020407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring25T_D.out -ele 10020507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring26T_D.out -ele 10020607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_D.out -ele 10030108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring32B_D.out -ele 10030208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring33B_D.out -ele 10030308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring34B_D.out -ele 10030408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring35B_D.out -ele 10030508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring36B_D.out -ele 10030608 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_D.out -ele 10030107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring32T_D.out -ele 10030207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring33T_D.out -ele 10030307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring34T_D.out -ele 10030407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring35T_D.out -ele 10030507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring36T_D.out -ele 10030607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_D.out -ele 10040108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring42B_D.out -ele 10040208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring43B_D.out -ele 10040308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring44B_D.out -ele 10040408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring45B_D.out -ele 10040508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring46B_D.out -ele 10040608 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring41T_D.out -ele 10040107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring42T_D.out -ele 10040207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring43T_D.out -ele 10040307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring44T_D.out -ele 10040407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring45T_D.out -ele 10040507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring46T_D.out -ele 10040607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring51B_D.out -ele 10050108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring52B_D.out -ele 10050208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring53B_D.out -ele 10050308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring54B_D.out -ele 10050408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring55B_D.out -ele 10050508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring56B_D.out -ele 10050608 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring51T_D.out -ele 10050107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring52T_D.out -ele 10050207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring53T_D.out -ele 10050307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring54T_D.out -ele 10050407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring55T_D.out -ele 10050507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring56T_D.out -ele 10050607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring61B_D.out -ele 10060108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring62B_D.out -ele 10060208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring63B_D.out -ele 10060308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring64B_D.out -ele 10060408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring65B_D.out -ele 10060508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring66B_D.out -ele 10060608 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring61T_D.out -ele 10060107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring62T_D.out -ele 10060207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring63T_D.out -ele 10060307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring64T_D.out -ele 10060407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring65T_D.out -ele 10060507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring66T_D.out -ele 10060607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring71B_D.out -ele 10070108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring72B_D.out -ele 10070208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring73B_D.out -ele 10070308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring74B_D.out -ele 10070408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring75B_D.out -ele 10070508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring76B_D.out -ele 10070608 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring71T_D.out -ele 10070107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring72T_D.out -ele 10070207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring73T_D.out -ele 10070307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring74T_D.out -ele 10070407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring75T_D.out -ele 10070507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring76T_D.out -ele 10070607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring81B_D.out -ele 10080108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring82B_D.out -ele 10080208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring83B_D.out -ele 10080308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring84B_D.out -ele 10080408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring85B_D.out -ele 10080508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring86B_D.out -ele 10080608 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring81T_D.out -ele 10080107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring82T_D.out -ele 10080207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring83T_D.out -ele 10080307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring84T_D.out -ele 10080407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring85T_D.out -ele 10080507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring86T_D.out -ele 10080607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring91B_D.out -ele 10090108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring92B_D.out -ele 10090208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring93B_D.out -ele 10090308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring94B_D.out -ele 10090408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring95B_D.out -ele 10090508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring96B_D.out -ele 10090608 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring91T_D.out -ele 10090107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring92T_D.out -ele 10090207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring93T_D.out -ele 10090307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring94T_D.out -ele 10090407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring95T_D.out -ele 10090507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring96T_D.out -ele 10090607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring101B_D.out -ele 10100108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring102B_D.out -ele 10100208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring103B_D.out -ele 10100308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring104B_D.out -ele 10100408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring105B_D.out -ele 10100508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring106B_D.out -ele 10100608 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring101T_D.out -ele 10100107 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring102T_D.out -ele 10100207 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring103T_D.out -ele 10100307 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring104T_D.out -ele 10100407 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring105T_D.out -ele 10100507 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring106T_D.out -ele 10100607 deformation;
recorder Element -file $MainFolder/$SubFolder/ColSpring111B_D.out -ele 10110108 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring112B_D.out -ele 10110208 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring113B_D.out -ele 10110308 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring114B_D.out -ele 10110408 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring115B_D.out -ele 10110508 deformation;  recorder Element -file $MainFolder/$SubFolder/ColSpring116B_D.out -ele 10110608 deformation;

# Beam springs forces
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_F.out -ele 10020109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_F.out -ele 10020210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_F.out -ele 10020209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_F.out -ele 10020310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_F.out -ele 10020309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_F.out -ele 10020410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24R_F.out -ele 10020409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring25L_F.out -ele 10020510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring25R_F.out -ele 10020509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring26L_F.out -ele 10020610 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_F.out -ele 10030109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_F.out -ele 10030210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_F.out -ele 10030209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_F.out -ele 10030310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_F.out -ele 10030309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_F.out -ele 10030410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34R_F.out -ele 10030409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring35L_F.out -ele 10030510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring35R_F.out -ele 10030509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring36L_F.out -ele 10030610 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_F.out -ele 10040109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_F.out -ele 10040210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_F.out -ele 10040209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_F.out -ele 10040310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_F.out -ele 10040309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_F.out -ele 10040410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44R_F.out -ele 10040409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring45L_F.out -ele 10040510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring45R_F.out -ele 10040509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring46L_F.out -ele 10040610 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring51R_F.out -ele 10050109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring52L_F.out -ele 10050210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring52R_F.out -ele 10050209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring53L_F.out -ele 10050310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring53R_F.out -ele 10050309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring54L_F.out -ele 10050410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring54R_F.out -ele 10050409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring55L_F.out -ele 10050510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring55R_F.out -ele 10050509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring56L_F.out -ele 10050610 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring61R_F.out -ele 10060109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring62L_F.out -ele 10060210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring62R_F.out -ele 10060209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring63L_F.out -ele 10060310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring63R_F.out -ele 10060309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring64L_F.out -ele 10060410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring64R_F.out -ele 10060409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring65L_F.out -ele 10060510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring65R_F.out -ele 10060509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring66L_F.out -ele 10060610 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring71R_F.out -ele 10070109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring72L_F.out -ele 10070210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring72R_F.out -ele 10070209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring73L_F.out -ele 10070310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring73R_F.out -ele 10070309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring74L_F.out -ele 10070410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring74R_F.out -ele 10070409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring75L_F.out -ele 10070510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring75R_F.out -ele 10070509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring76L_F.out -ele 10070610 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring81R_F.out -ele 10080109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring82L_F.out -ele 10080210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring82R_F.out -ele 10080209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring83L_F.out -ele 10080310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring83R_F.out -ele 10080309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring84L_F.out -ele 10080410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring84R_F.out -ele 10080409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring85L_F.out -ele 10080510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring85R_F.out -ele 10080509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring86L_F.out -ele 10080610 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring91R_F.out -ele 10090109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring92L_F.out -ele 10090210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring92R_F.out -ele 10090209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring93L_F.out -ele 10090310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring93R_F.out -ele 10090309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring94L_F.out -ele 10090410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring94R_F.out -ele 10090409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring95L_F.out -ele 10090510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring95R_F.out -ele 10090509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring96L_F.out -ele 10090610 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring101R_F.out -ele 10100109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring102L_F.out -ele 10100210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring102R_F.out -ele 10100209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring103L_F.out -ele 10100310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring103R_F.out -ele 10100309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring104L_F.out -ele 10100410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring104R_F.out -ele 10100409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring105L_F.out -ele 10100510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring105R_F.out -ele 10100509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring106L_F.out -ele 10100610 force;
recorder Element -file $MainFolder/$SubFolder/BeamSpring111R_F.out -ele 10110109 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring112L_F.out -ele 10110210 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring112R_F.out -ele 10110209 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring113L_F.out -ele 10110310 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring113R_F.out -ele 10110309 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring114L_F.out -ele 10110410 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring114R_F.out -ele 10110409 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring115L_F.out -ele 10110510 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring115R_F.out -ele 10110509 force;  recorder Element -file $MainFolder/$SubFolder/BeamSpring116L_F.out -ele 10110610 force;

# Beam springs rotations
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_D.out -ele 10020109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_D.out -ele 10020210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_D.out -ele 10020209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_D.out -ele 10020310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_D.out -ele 10020309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_D.out -ele 10020410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring24R_D.out -ele 10020409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring25L_D.out -ele 10020510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring25R_D.out -ele 10020509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring26L_D.out -ele 10020610 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_D.out -ele 10030109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_D.out -ele 10030210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_D.out -ele 10030209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_D.out -ele 10030310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_D.out -ele 10030309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_D.out -ele 10030410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring34R_D.out -ele 10030409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring35L_D.out -ele 10030510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring35R_D.out -ele 10030509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring36L_D.out -ele 10030610 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_D.out -ele 10040109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_D.out -ele 10040210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_D.out -ele 10040209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_D.out -ele 10040310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_D.out -ele 10040309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_D.out -ele 10040410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring44R_D.out -ele 10040409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring45L_D.out -ele 10040510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring45R_D.out -ele 10040509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring46L_D.out -ele 10040610 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring51R_D.out -ele 10050109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring52L_D.out -ele 10050210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring52R_D.out -ele 10050209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring53L_D.out -ele 10050310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring53R_D.out -ele 10050309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring54L_D.out -ele 10050410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring54R_D.out -ele 10050409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring55L_D.out -ele 10050510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring55R_D.out -ele 10050509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring56L_D.out -ele 10050610 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring61R_D.out -ele 10060109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring62L_D.out -ele 10060210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring62R_D.out -ele 10060209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring63L_D.out -ele 10060310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring63R_D.out -ele 10060309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring64L_D.out -ele 10060410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring64R_D.out -ele 10060409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring65L_D.out -ele 10060510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring65R_D.out -ele 10060509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring66L_D.out -ele 10060610 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring71R_D.out -ele 10070109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring72L_D.out -ele 10070210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring72R_D.out -ele 10070209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring73L_D.out -ele 10070310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring73R_D.out -ele 10070309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring74L_D.out -ele 10070410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring74R_D.out -ele 10070409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring75L_D.out -ele 10070510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring75R_D.out -ele 10070509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring76L_D.out -ele 10070610 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring81R_D.out -ele 10080109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring82L_D.out -ele 10080210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring82R_D.out -ele 10080209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring83L_D.out -ele 10080310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring83R_D.out -ele 10080309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring84L_D.out -ele 10080410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring84R_D.out -ele 10080409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring85L_D.out -ele 10080510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring85R_D.out -ele 10080509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring86L_D.out -ele 10080610 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring91R_D.out -ele 10090109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring92L_D.out -ele 10090210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring92R_D.out -ele 10090209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring93L_D.out -ele 10090310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring93R_D.out -ele 10090309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring94L_D.out -ele 10090410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring94R_D.out -ele 10090409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring95L_D.out -ele 10090510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring95R_D.out -ele 10090509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring96L_D.out -ele 10090610 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring101R_D.out -ele 10100109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring102L_D.out -ele 10100210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring102R_D.out -ele 10100209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring103L_D.out -ele 10100310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring103R_D.out -ele 10100309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring104L_D.out -ele 10100410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring104R_D.out -ele 10100409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring105L_D.out -ele 10100510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring105R_D.out -ele 10100509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring106L_D.out -ele 10100610 deformation;
recorder Element -file $MainFolder/$SubFolder/BeamSpring111R_D.out -ele 10110109 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring112L_D.out -ele 10110210 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring112R_D.out -ele 10110209 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring113L_D.out -ele 10110310 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring113R_D.out -ele 10110309 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring114L_D.out -ele 10110410 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring114R_D.out -ele 10110409 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring115L_D.out -ele 10110510 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring115R_D.out -ele 10110509 deformation;  recorder Element -file $MainFolder/$SubFolder/BeamSpring116L_D.out -ele 10110610 deformation;

# Panel zone spring forces (if any)
recorder Element -file $MainFolder/$SubFolder/PZ21_F.out -ele 11020100 force;  recorder Element -file $MainFolder/$SubFolder/PZ22_F.out -ele 11020200 force;  recorder Element -file $MainFolder/$SubFolder/PZ23_F.out -ele 11020300 force;  recorder Element -file $MainFolder/$SubFolder/PZ24_F.out -ele 11020400 force;  recorder Element -file $MainFolder/$SubFolder/PZ25_F.out -ele 11020500 force;  recorder Element -file $MainFolder/$SubFolder/PZ26_F.out -ele 11020600 force;
recorder Element -file $MainFolder/$SubFolder/PZ31_F.out -ele 11030100 force;  recorder Element -file $MainFolder/$SubFolder/PZ32_F.out -ele 11030200 force;  recorder Element -file $MainFolder/$SubFolder/PZ33_F.out -ele 11030300 force;  recorder Element -file $MainFolder/$SubFolder/PZ34_F.out -ele 11030400 force;  recorder Element -file $MainFolder/$SubFolder/PZ35_F.out -ele 11030500 force;  recorder Element -file $MainFolder/$SubFolder/PZ36_F.out -ele 11030600 force;
recorder Element -file $MainFolder/$SubFolder/PZ41_F.out -ele 11040100 force;  recorder Element -file $MainFolder/$SubFolder/PZ42_F.out -ele 11040200 force;  recorder Element -file $MainFolder/$SubFolder/PZ43_F.out -ele 11040300 force;  recorder Element -file $MainFolder/$SubFolder/PZ44_F.out -ele 11040400 force;  recorder Element -file $MainFolder/$SubFolder/PZ45_F.out -ele 11040500 force;  recorder Element -file $MainFolder/$SubFolder/PZ46_F.out -ele 11040600 force;
recorder Element -file $MainFolder/$SubFolder/PZ51_F.out -ele 11050100 force;  recorder Element -file $MainFolder/$SubFolder/PZ52_F.out -ele 11050200 force;  recorder Element -file $MainFolder/$SubFolder/PZ53_F.out -ele 11050300 force;  recorder Element -file $MainFolder/$SubFolder/PZ54_F.out -ele 11050400 force;  recorder Element -file $MainFolder/$SubFolder/PZ55_F.out -ele 11050500 force;  recorder Element -file $MainFolder/$SubFolder/PZ56_F.out -ele 11050600 force;
recorder Element -file $MainFolder/$SubFolder/PZ61_F.out -ele 11060100 force;  recorder Element -file $MainFolder/$SubFolder/PZ62_F.out -ele 11060200 force;  recorder Element -file $MainFolder/$SubFolder/PZ63_F.out -ele 11060300 force;  recorder Element -file $MainFolder/$SubFolder/PZ64_F.out -ele 11060400 force;  recorder Element -file $MainFolder/$SubFolder/PZ65_F.out -ele 11060500 force;  recorder Element -file $MainFolder/$SubFolder/PZ66_F.out -ele 11060600 force;
recorder Element -file $MainFolder/$SubFolder/PZ71_F.out -ele 11070100 force;  recorder Element -file $MainFolder/$SubFolder/PZ72_F.out -ele 11070200 force;  recorder Element -file $MainFolder/$SubFolder/PZ73_F.out -ele 11070300 force;  recorder Element -file $MainFolder/$SubFolder/PZ74_F.out -ele 11070400 force;  recorder Element -file $MainFolder/$SubFolder/PZ75_F.out -ele 11070500 force;  recorder Element -file $MainFolder/$SubFolder/PZ76_F.out -ele 11070600 force;
recorder Element -file $MainFolder/$SubFolder/PZ81_F.out -ele 11080100 force;  recorder Element -file $MainFolder/$SubFolder/PZ82_F.out -ele 11080200 force;  recorder Element -file $MainFolder/$SubFolder/PZ83_F.out -ele 11080300 force;  recorder Element -file $MainFolder/$SubFolder/PZ84_F.out -ele 11080400 force;  recorder Element -file $MainFolder/$SubFolder/PZ85_F.out -ele 11080500 force;  recorder Element -file $MainFolder/$SubFolder/PZ86_F.out -ele 11080600 force;
recorder Element -file $MainFolder/$SubFolder/PZ91_F.out -ele 11090100 force;  recorder Element -file $MainFolder/$SubFolder/PZ92_F.out -ele 11090200 force;  recorder Element -file $MainFolder/$SubFolder/PZ93_F.out -ele 11090300 force;  recorder Element -file $MainFolder/$SubFolder/PZ94_F.out -ele 11090400 force;  recorder Element -file $MainFolder/$SubFolder/PZ95_F.out -ele 11090500 force;  recorder Element -file $MainFolder/$SubFolder/PZ96_F.out -ele 11090600 force;
recorder Element -file $MainFolder/$SubFolder/PZ101_F.out -ele 11100100 force;  recorder Element -file $MainFolder/$SubFolder/PZ102_F.out -ele 11100200 force;  recorder Element -file $MainFolder/$SubFolder/PZ103_F.out -ele 11100300 force;  recorder Element -file $MainFolder/$SubFolder/PZ104_F.out -ele 11100400 force;  recorder Element -file $MainFolder/$SubFolder/PZ105_F.out -ele 11100500 force;  recorder Element -file $MainFolder/$SubFolder/PZ106_F.out -ele 11100600 force;
recorder Element -file $MainFolder/$SubFolder/PZ111_F.out -ele 11110100 force;  recorder Element -file $MainFolder/$SubFolder/PZ112_F.out -ele 11110200 force;  recorder Element -file $MainFolder/$SubFolder/PZ113_F.out -ele 11110300 force;  recorder Element -file $MainFolder/$SubFolder/PZ114_F.out -ele 11110400 force;  recorder Element -file $MainFolder/$SubFolder/PZ115_F.out -ele 11110500 force;  recorder Element -file $MainFolder/$SubFolder/PZ116_F.out -ele 11110600 force;

# Panel zone spring deforamtions (if any)
recorder Element -file $MainFolder/$SubFolder/PZ21_D.out -ele 11020100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ22_D.out -ele 11020200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ23_D.out -ele 11020300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ24_D.out -ele 11020400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ25_D.out -ele 11020500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ26_D.out -ele 11020600 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ31_D.out -ele 11030100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ32_D.out -ele 11030200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ33_D.out -ele 11030300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ34_D.out -ele 11030400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ35_D.out -ele 11030500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ36_D.out -ele 11030600 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ41_D.out -ele 11040100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ42_D.out -ele 11040200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ43_D.out -ele 11040300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ44_D.out -ele 11040400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ45_D.out -ele 11040500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ46_D.out -ele 11040600 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ51_D.out -ele 11050100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ52_D.out -ele 11050200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ53_D.out -ele 11050300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ54_D.out -ele 11050400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ55_D.out -ele 11050500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ56_D.out -ele 11050600 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ61_D.out -ele 11060100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ62_D.out -ele 11060200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ63_D.out -ele 11060300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ64_D.out -ele 11060400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ65_D.out -ele 11060500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ66_D.out -ele 11060600 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ71_D.out -ele 11070100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ72_D.out -ele 11070200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ73_D.out -ele 11070300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ74_D.out -ele 11070400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ75_D.out -ele 11070500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ76_D.out -ele 11070600 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ81_D.out -ele 11080100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ82_D.out -ele 11080200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ83_D.out -ele 11080300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ84_D.out -ele 11080400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ85_D.out -ele 11080500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ86_D.out -ele 11080600 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ91_D.out -ele 11090100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ92_D.out -ele 11090200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ93_D.out -ele 11090300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ94_D.out -ele 11090400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ95_D.out -ele 11090500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ96_D.out -ele 11090600 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ101_D.out -ele 11100100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ102_D.out -ele 11100200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ103_D.out -ele 11100300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ104_D.out -ele 11100400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ105_D.out -ele 11100500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ106_D.out -ele 11100600 deformation;
recorder Element -file $MainFolder/$SubFolder/PZ111_D.out -ele 11110100 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ112_D.out -ele 11110200 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ113_D.out -ele 11110300 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ114_D.out -ele 11110400 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ115_D.out -ele 11110500 deformation;  recorder Element -file $MainFolder/$SubFolder/PZ116_D.out -ele 11110600 deformation;

# ------------------------------------- Mass -------------------------------------

# Moment frame mass
set g 9810.0;
mass 11020104 96.600 1.e-9 1.e-9;  mass 11020204 96.600 1.e-9 1.e-9;  mass 11020304 96.600 1.e-9 1.e-9;  mass 11020404 96.600 1.e-9 1.e-9;  mass 11020504 96.600 1.e-9 1.e-9;  mass 11020604 96.600 1.e-9 1.e-9;
mass 11030104 101.000 1.e-9 1.e-9;  mass 11030204 101.000 1.e-9 1.e-9;  mass 11030304 101.000 1.e-9 1.e-9;  mass 11030404 101.000 1.e-9 1.e-9;  mass 11030504 101.000 1.e-9 1.e-9;  mass 11030604 101.000 1.e-9 1.e-9;
mass 11040104 99.000 1.e-9 1.e-9;  mass 11040204 99.000 1.e-9 1.e-9;  mass 11040304 99.000 1.e-9 1.e-9;  mass 11040404 99.000 1.e-9 1.e-9;  mass 11040504 99.000 1.e-9 1.e-9;  mass 11040604 99.000 1.e-9 1.e-9;
mass 11050104 99.000 1.e-9 1.e-9;  mass 11050204 99.000 1.e-9 1.e-9;  mass 11050304 99.000 1.e-9 1.e-9;  mass 11050404 99.000 1.e-9 1.e-9;  mass 11050504 99.000 1.e-9 1.e-9;  mass 11050604 99.000 1.e-9 1.e-9;
mass 11060104 99.000 1.e-9 1.e-9;  mass 11060204 99.000 1.e-9 1.e-9;  mass 11060304 99.000 1.e-9 1.e-9;  mass 11060404 99.000 1.e-9 1.e-9;  mass 11060504 99.000 1.e-9 1.e-9;  mass 11060604 99.000 1.e-9 1.e-9;
mass 11070104 99.000 1.e-9 1.e-9;  mass 11070204 99.000 1.e-9 1.e-9;  mass 11070304 99.000 1.e-9 1.e-9;  mass 11070404 99.000 1.e-9 1.e-9;  mass 11070504 99.000 1.e-9 1.e-9;  mass 11070604 99.000 1.e-9 1.e-9;
mass 11080104 99.000 1.e-9 1.e-9;  mass 11080204 99.000 1.e-9 1.e-9;  mass 11080304 99.000 1.e-9 1.e-9;  mass 11080404 99.000 1.e-9 1.e-9;  mass 11080504 99.000 1.e-9 1.e-9;  mass 11080604 99.000 1.e-9 1.e-9;
mass 11090104 99.000 1.e-9 1.e-9;  mass 11090204 99.000 1.e-9 1.e-9;  mass 11090304 99.000 1.e-9 1.e-9;  mass 11090404 99.000 1.e-9 1.e-9;  mass 11090504 99.000 1.e-9 1.e-9;  mass 11090604 99.000 1.e-9 1.e-9;
mass 11100104 99.000 1.e-9 1.e-9;  mass 11100204 99.000 1.e-9 1.e-9;  mass 11100304 99.000 1.e-9 1.e-9;  mass 11100404 99.000 1.e-9 1.e-9;  mass 11100504 99.000 1.e-9 1.e-9;  mass 11100604 99.000 1.e-9 1.e-9;
mass 11110104 107.000 1.e-9 1.e-9;  mass 11110204 107.000 1.e-9 1.e-9;  mass 11110304 107.000 1.e-9 1.e-9;  mass 11110404 107.000 1.e-9 1.e-9;  mass 11110504 107.000 1.e-9 1.e-9;  mass 11110604 107.000 1.e-9 1.e-9;

# Leaning column mass
mass 10020700 0.000 1.e-9 1.e-9;
mass 10030700 0.000 1.e-9 1.e-9;
mass 10040700 0.000 1.e-9 1.e-9;
mass 10050700 0.000 1.e-9 1.e-9;
mass 10060700 0.000 1.e-9 1.e-9;
mass 10070700 0.000 1.e-9 1.e-9;
mass 10080700 0.000 1.e-9 1.e-9;
mass 10090700 0.000 1.e-9 1.e-9;
mass 10100700 0.000 1.e-9 1.e-9;
mass 10110700 0.000 1.e-9 1.e-9;


# -------------------------------- Eigen analysis --------------------------------

set pi [expr 2.0*asin(1.0)];
set nEigen 10
set lambdaN [eigen [expr $nEigen]];
set lambda1 [lindex $lambdaN 0];
set lambda2 [lindex $lambdaN 1];
set lambda3 [lindex $lambdaN 2];
set lambda4 [lindex $lambdaN 3];
set lambda5 [lindex $lambdaN 4];
set lambda6 [lindex $lambdaN 5];
set lambda7 [lindex $lambdaN 6];
set lambda8 [lindex $lambdaN 7];
set lambda9 [lindex $lambdaN 8];
set lambda10 [lindex $lambdaN 9];
set w1 [expr pow($lambda1, 0.5)];
set w2 [expr pow($lambda2, 0.5)];
set w3 [expr pow($lambda3, 0.5)];
set w4 [expr pow($lambda4, 0.5)];
set w5 [expr pow($lambda5, 0.5)];
set w6 [expr pow($lambda6, 0.5)];
set w7 [expr pow($lambda7, 0.5)];
set w8 [expr pow($lambda8, 0.5)];
set w9 [expr pow($lambda9, 0.5)];
set w10 [expr pow($lambda10, 0.5)];
set T1 [expr round(2.0*$pi/$w1 *1000.)/1000.];
set T2 [expr round(2.0*$pi/$w2 *1000.)/1000.];
set T3 [expr round(2.0*$pi/$w3 *1000.)/1000.];
set T4 [expr round(2.0*$pi/$w4 *1000.)/1000.];
set T5 [expr round(2.0*$pi/$w5 *1000.)/1000.];
set T6 [expr round(2.0*$pi/$w6 *1000.)/1000.];
set T7 [expr round(2.0*$pi/$w7 *1000.)/1000.];
set T8 [expr round(2.0*$pi/$w8 *1000.)/1000.];
set T9 [expr round(2.0*$pi/$w9 *1000.)/1000.];
set T10 [expr round(2.0*$pi/$w10 *1000.)/1000.];
puts "T1 = $T1 s";
puts "T2 = $T2 s";
puts "T3 = $T3 s";

set fileX [open "$MainFolder/EigenAnalysis/EigenPeriod.out" w];
puts $fileX $T1;
puts $fileX $T2;
puts $fileX $T3;
puts $fileX $T4;
puts $fileX $T5;
puts $fileX $T6;
puts $fileX $T7;
puts $fileX $T8;
puts $fileX $T9;
puts $fileX $T10;
close $fileX;


# --------------------------- Static gravity analysis ----------------------------

pattern Plain 100 Linear {

    # Moment frame loads
    load 11020101 0. -966000.0 0.;      load 11020201 0. -966000.0 0.;      load 11020301 0. -966000.0 0.;      load 11020401 0. -966000.0 0.;      load 11020501 0. -966000.0 0.;      load 11020601 0. -966000.0 0.;
    load 11030101 0. -1010000.0 0.;      load 11030201 0. -1010000.0 0.;      load 11030301 0. -1010000.0 0.;      load 11030401 0. -1010000.0 0.;      load 11030501 0. -1010000.0 0.;      load 11030601 0. -1010000.0 0.;
    load 11040101 0. -990000.0 0.;      load 11040201 0. -990000.0 0.;      load 11040301 0. -990000.0 0.;      load 11040401 0. -990000.0 0.;      load 11040501 0. -990000.0 0.;      load 11040601 0. -990000.0 0.;
    load 11050101 0. -990000.0 0.;      load 11050201 0. -990000.0 0.;      load 11050301 0. -990000.0 0.;      load 11050401 0. -990000.0 0.;      load 11050501 0. -990000.0 0.;      load 11050601 0. -990000.0 0.;
    load 11060101 0. -990000.0 0.;      load 11060201 0. -990000.0 0.;      load 11060301 0. -990000.0 0.;      load 11060401 0. -990000.0 0.;      load 11060501 0. -990000.0 0.;      load 11060601 0. -990000.0 0.;
    load 11070101 0. -990000.0 0.;      load 11070201 0. -990000.0 0.;      load 11070301 0. -990000.0 0.;      load 11070401 0. -990000.0 0.;      load 11070501 0. -990000.0 0.;      load 11070601 0. -990000.0 0.;
    load 11080101 0. -990000.0 0.;      load 11080201 0. -990000.0 0.;      load 11080301 0. -990000.0 0.;      load 11080401 0. -990000.0 0.;      load 11080501 0. -990000.0 0.;      load 11080601 0. -990000.0 0.;
    load 11090101 0. -990000.0 0.;      load 11090201 0. -990000.0 0.;      load 11090301 0. -990000.0 0.;      load 11090401 0. -990000.0 0.;      load 11090501 0. -990000.0 0.;      load 11090601 0. -990000.0 0.;
    load 11100101 0. -990000.0 0.;      load 11100201 0. -990000.0 0.;      load 11100301 0. -990000.0 0.;      load 11100401 0. -990000.0 0.;      load 11100501 0. -990000.0 0.;      load 11100601 0. -990000.0 0.;
    load 11110101 0. -1070000.0 0.;      load 11110201 0. -1070000.0 0.;      load 11110301 0. -1070000.0 0.;      load 11110401 0. -1070000.0 0.;      load 11110501 0. -1070000.0 0.;      load 11110601 0. -1070000.0 0.;

    # gravity frame loads
    load 10020700 0. -0.4 0.;
    load 10030700 0. -0.4 0.;
    load 10040700 0. -0.4 0.;
    load 10050700 0. -0.4 0.;
    load 10060700 0. -0.4 0.;
    load 10070700 0. -0.4 0.;
    load 10080700 0. -0.4 0.;
    load 10090700 0. -0.4 0.;
    load 10100700 0. -0.4 0.;
    load 10110700 0. -0.3 0.;

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
    set beam_Ids [list 10020104 10020204 10020304 10020404 10020504 10030104 10030204 10030304 10030404 10030504 10040104 10040204 10040304 10040404 10040504 10050104 10050204 10050304 10050404 10050504 10060104 10060204 10060304 10060404 10060504 10070104 10070204 10070304 10070404 10070504 10080104 10080204 10080304 10080404 10080504 10090104 10090204 10090304 10090404 10090504 10100104 10100204 10100304 10100404 10100504 10110104 10110204 10110304 10110404 10110504];
    set column_Ids [list 10010101 10010201 10010301 10010401 10010501 10010601 10020101 10020201 10020301 10020401 10020501 10020601 10030102 10030103 10030202 10030203 10030302 10030303 10030402 10030403 10030502 10030503 10030602 10030603 10040101 10040201 10040301 10040401 10040501 10040601 10050102 10050103 10050202 10050203 10050302 10050303 10050402 10050403 10050502 10050503 10050602 10050603 10060101 10060201 10060301 10060401 10060501 10060601 10070102 10070103 10070202 10070203 10070302 10070303 10070402 10070403 10070502 10070503 10070602 10070603 10080101 10080201 10080301 10080401 10080501 10080601 10090102 10090103 10090202 10090203 10090302 10090303 10090402 10090403 10090502 10090503 10090602 10090603 10100101 10100201 10100301 10100401 10100501 10100601];
    set mass_Ids [list 11020104 11020204 11020304 11020404 11020504 11020604 11020704 11020804 11020904 11021004 11030104 11030204 11030304 11030404 11030504 11030604 11030704 11030804 11030904 11031004 11040104 11040204 11040304 11040404 11040504 11040604 11040704 11040804 11040904 11041004 11050104 11050204 11050304 11050404 11050504 11050604 11050704 11050804 11050904 11051004 11060104 11060204 11060304 11060404 11060504 11060604 11060704 11060804 11060904 11061004 11070104 11070204 11070304 11070404 11070504 11070604 11070704 11070804 11070904 11071004 11080104 11080204 11080304 11080404 11080504 11080604 11080704 11080804 11080904 11081004 11090104 11090204 11090304 11090404 11090504 11090604 11090704 11090804 11090904 11091004 11100104 11100204 11100304 11100404 11100504 11100604 11100704 11100804 11100904 11101004 11110104 11110204 11110304 11110404 11110504 11110604 11110704 11110804 11110904 11111004 10020700 10030700 10040700 10050700 10060700 10070700 10080700 10090700 10100700 10110700];
    # region 1 -ele {*}$beam_Ids -rayleigh 0.0 0.0 $a1_mod 0.0;
    # region 2 -ele {*}$column_Ids -rayleigh 0.0 0.0 $a1_mod 0.0;
    # region 3 -ele {*}$mass_Ids -rayleigh $a0 0.0 0.0 0.0;
    rayleigh $a0 0.0 $a1 0.0;

    # Ground motion acceleration file input
    set AccelSeries "Series -dt $GMdt -filePath $GMFile -factor [expr $EqSF * $g]";
    pattern UniformExcitation 200 1 -accel $AccelSeries;
    set MF_FloorNodes [list 11020304 11030304 11040304 11050304 11060304 11070304 11080304 11090304 11100304 11110304];
    set GMduration [expr $GMdt*$GMpoints];
    set NumSteps [expr round(($GMduration + $FVduration)/$GMdt)];
    set totTime [expr $GMdt*$NumSteps]; 
    set dtAnalysis [expr 1.0*$GMdt]; 
    DynamicAnalysisCollapseSolverX $GMdt $dtAnalysis $totTime $NStory 0.15 $MF_FloorNodes $MF_FloorNodes 3650.0 5490.0 1 $StartTime $MaxRunTime $GMname;

}


# ------------------------------ Pushover analysis -------------------------------

if {$PO == 1} {

    set m2 579.600;
    set m3 606.000;
    set m4 594.000;
    set m5 594.000;
    set m6 594.000;
    set m7 594.000;
    set m8 594.000;
    set m9 594.000;
    set m10 594.000;
    set m11 642.000;

    set file [open "$MainFolder/EigenAnalysis/EigenVectorsMode1.out" r];
    set first_line [gets $file];
    close $file
    set mode_list [split $first_line];
    set F2 [expr $m2 * [lindex $mode_list 0]];
    set F3 [expr $m3 * [lindex $mode_list 1]];
    set F4 [expr $m4 * [lindex $mode_list 2]];
    set F5 [expr $m5 * [lindex $mode_list 3]];
    set F6 [expr $m6 * [lindex $mode_list 4]];
    set F7 [expr $m7 * [lindex $mode_list 5]];
    set F8 [expr $m8 * [lindex $mode_list 6]];
    set F9 [expr $m9 * [lindex $mode_list 7]];
    set F10 [expr $m10 * [lindex $mode_list 8]];
    set F11 [expr $m11 * [lindex $mode_list 9]];
    pattern Plain 222 Linear {
        load 11020304 $F2 0.0 0.0;
        load 11030304 $F3 0.0 0.0;
        load 11040304 $F4 0.0 0.0;
        load 11050304 $F5 0.0 0.0;
        load 11060304 $F6 0.0 0.0;
        load 11070304 $F7 0.0 0.0;
        load 11080304 $F8 0.0 0.0;
        load 11090304 $F9 0.0 0.0;
        load 11100304 $F10 0.0 0.0;
        load 11110304 $F11 0.0 0.0;
    };
    set CtrlNode 11110304;
    set CtrlDOF 1;
    set Dmax [expr 0.100*$Floor11];
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
# Frame name: 9S_Benchmark
# Generation time: 2024-03-17 23:02:57.624455
# All units are in [N, mm, t]
# 
# 
# --------------- 1. Building Geometry ---------------
# 
# Building height: 40820
# Number of story: 10
# Number of bays: 5
# Plane dimensions [mm]: 45750 x 45750
# Number of moment frames: 6
# External column tributary area [mm]: 4575.0 x 4575.0
# Internal column tributary area [mm]: 9150 x 4575.0
# 
# 
# --------------- 2. Structural Components ---------------
# 
# Beam sections:
#  Floor   Bay-1   Bay-2   Bay-3   Bay-4   Bay-5
#      2 W36x160 W36x160 W36x160 W36x160 W36x160
#      3 W36x160 W36x160 W36x160 W36x160 W36x160
#      4 W36x160 W36x160 W36x160 W36x160 W36x160
#      5 W36x135 W36x135 W36x135 W36x135 W36x135
#      6 W36x135 W36x135 W36x135 W36x135 W36x135
#      7 W36x135 W36x135 W36x135 W36x135 W36x135
#      8 W36x135 W36x135 W36x135 W36x135 W36x135
#      9  W30x99  W30x99  W30x99  W30x99  W30x99
#     10  W27x84  W27x84  W27x84  W27x84  W27x84
#     11  W24x68  W24x68  W24x68  W24x68  W24x68
# 
# Column sections:
#  Story  Axis-1  Axis-2  Axis-3  Axis-4  Axis-5  Axis-6
#      1 W14x500 W14x500 W14x500 W14x500 W14x500 W14x500
#      2 W14x500 W14x500 W14x500 W14x500 W14x500 W14x500
#      3 W14x455 W14x455 W14x455 W14x455 W14x455 W14x455
#      4 W14x455 W14x455 W14x455 W14x455 W14x455 W14x455
#      5 W14x370 W14x370 W14x370 W14x370 W14x370 W14x370
#      6 W14x370 W14x370 W14x370 W14x370 W14x370 W14x370
#      7 W14x283 W14x283 W14x283 W14x283 W14x283 W14x283
#      8 W14x283 W14x283 W14x283 W14x283 W14x283 W14x283
#      9 W14x257 W14x257 W14x257 W14x257 W14x257 W14x257
#     10 W14x257 W14x257 W14x257 W14x257 W14x257 W14x257
# 
# Stories with column splices: 3, 5, 7, 9
# 
# Doubler plate thickness [mm]:
#  Floor  Axis-1  Axis-2  Axis-3  Axis-4  Axis-5  Axis-6
#      2       0       0       0       0       0       0
#      3       0       0       0       0       0       0
#      4       0       0       0       0       0       0
#      5       0       0       0       0       0       0
#      6       0       0       0       0       0       0
#      7       0       0       0       0       0       0
#      8       0       0       0       0       0       0
#      9       0       0       0       0       0       0
#     10       0       0       0       0       0       0
#     11       0       0       0       0       0       0
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
#         4/5 1.000000e-09 1.000000e-09 1.000000e-09
#         5/6 1.000000e-09 1.000000e-09 1.000000e-09
#         6/7 1.000000e-09 1.000000e-09 1.000000e-09
#         7/8 1.000000e-09 1.000000e-09 1.000000e-09
#         8/9 1.000000e-09 1.000000e-09 1.000000e-09
#        9/10 1.000000e-09 1.000000e-09 1.000000e-09
#       10/11 1.000000e-09 1.000000e-09 1.000000e-09
# 
# Load and mass combination coefficients:
#         Dead  Live  Cladding
# Weight  1.05  0.25      1.05
# Mass    1.00  0.00      1.00
# 
# Axial compressive ratio of columns:
# Story       Axis-1       Axis-2       Axis-3       Axis-4       Axis-5       Axis-6
#    1b 3.346803e-07 3.484489e-07 3.484489e-07 3.484489e-07 3.484489e-07 3.346803e-07
#    1t 3.346803e-07 3.484489e-07 3.484489e-07 3.484489e-07 3.484489e-07 3.346803e-07
#    2b 3.011185e-07 3.134165e-07 3.134165e-07 3.134165e-07 3.134165e-07 3.011185e-07
#    2t 3.011185e-07 3.134165e-07 3.134165e-07 3.134165e-07 3.134165e-07 3.011185e-07
#    3b 2.934899e-07 3.053440e-07 3.053440e-07 3.053440e-07 3.053440e-07 2.934899e-07
#    3t 2.934899e-07 3.053440e-07 3.053440e-07 3.053440e-07 3.053440e-07 2.934899e-07
#    4b 2.567657e-07 2.671000e-07 2.671000e-07 2.671000e-07 2.671000e-07 2.567657e-07
#    4t 2.567657e-07 2.671000e-07 2.671000e-07 2.671000e-07 2.671000e-07 2.567657e-07
#    5b 2.705097e-07 2.813461e-07 2.813461e-07 2.813461e-07 2.813461e-07 2.705097e-07
#    5t 2.705097e-07 2.813461e-07 2.813461e-07 2.813461e-07 2.813461e-07 2.705097e-07
#    6b 2.253626e-07 2.343306e-07 2.343306e-07 2.343306e-07 2.343306e-07 2.253626e-07
#    6t 2.253626e-07 2.343306e-07 2.343306e-07 2.343306e-07 2.343306e-07 2.253626e-07
#    7b 2.358160e-07 2.451062e-07 2.451062e-07 2.451062e-07 2.451062e-07 2.358160e-07
#    7t 2.358160e-07 2.451062e-07 2.451062e-07 2.451062e-07 2.451062e-07 2.358160e-07
#    8b 1.767399e-07 1.835854e-07 1.835854e-07 1.835854e-07 1.835854e-07 1.767399e-07
#    8t 1.767399e-07 1.835854e-07 1.835854e-07 1.835854e-07 1.835854e-07 1.767399e-07
#    9b 1.296480e-07 1.344970e-07 1.344970e-07 1.344970e-07 1.344970e-07 1.296480e-07
#    9t 1.296480e-07 1.344970e-07 1.344970e-07 1.344970e-07 1.344970e-07 1.296480e-07
#   10b 6.455484e-08 6.671019e-08 6.671019e-08 6.671019e-08 6.671019e-08 6.455484e-08
#   10t 6.455484e-08 6.671019e-08 6.671019e-08 6.671019e-08 6.671019e-08 6.455484e-08
# 
# Seiemic weight of considered 2D frame: 59856.00 kN
# Seiemic mass of considered 2D frame: 5985.60 t
# 
# 
# --------------- 4. Connection and Boundary Condition ---------------
# 
# Base support: Pinned
# Beam-to-column connection: Fully constrained connection
# Consider panel zone deformation: Yes (Parallelogram)
# 

