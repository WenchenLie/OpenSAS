####################################################################################################
####################################################################################################
#                                        8-story CBF Building
####################################################################################################
####################################################################################################

# CLEAR ALL;
wipe all;

# BUILD MODEL (2D - 3 DOF/node)
model basic -ndm 2 -ndf 3

####################################################################################################
#                                        BASIC MODEL VARIABLES                                     #
####################################################################################################

set  global RunTime;
set  global StartTime;
set  global MaxRunTime;
set  MaxRunTime [expr 10.0000 * 60.];
set  StartTime [clock seconds];
set  RunTime 0.0;
set  EQ 0;
set  PO 0;
set  ELF 0;
set  Composite 0;
set  ShowAnimation 1;
set  MainDir {C:\Dropbox\Under Development\FM-2D};
set  RFpath {C:\Users\ahmed\Downloads\8Story_CBF};
set  MainFolder {C:\Users\ahmed\Downloads\8Story_CBF\Results};
set  ModePO 1;
set  DriftPO 0.100000;
set  DampModeI 1;
set  DampModeJ 3;
set  zeta 0.020000;

####################################################################################################
#                                       SOURCING SUBROUTINES                                       #
####################################################################################################

source DisplayModel3D.tcl;
source DisplayPlane.tcl;
source Spring_PZ.tcl;
source Spring_IMK.tcl;
source Spring_Zero.tcl;
source Spring_Rigid.tcl;
source Spring_Pinching.tcl;
source Spring_Pinching.tcl;
source ConstructPanel_Rectangle.tcl;
source ConstructBrace.tcl;
source Spring_Gusset.tcl;
source FatigueMat.tcl;
source ConstructFiberColumn.tcl;
source FiberRHSS.tcl;
source FiberCHSS.tcl;
source FiberWF.tcl;
source DynamicAnalysisCollapseSolverX.tcl;
source Generate_lognrmrand.tcl;

####################################################################################################
#                                          Create Results Folders                                  #
####################################################################################################

# RESULT FOLDER
set SubFolder  $GMname;
cd $RFpath;
file mkdir "Results";
cd "Results"
file mkdir $SubFolder;
cd $MainDir;

####################################################################################################
#                                              INPUT                                               #
####################################################################################################

# FRAME CENTERLINE DIMENSIONS
set NStory  8;
set NBay    1;

# MATERIAL PROPERTIES
set E   210.000;
set mu  0.300; 
set fy  [expr 0.345 *   1.0];
set fyB [expr 0.345 *   1.0];
set fyG [expr 0.345 *   1.0];

# BASIC MATERIALS
uniaxialMaterial Elastic  9  1.e-9; 		#Flexible Material 
uniaxialMaterial Elastic  99 1000000000.;  #Rigid Material 
uniaxialMaterial UVCuniaxial  666 210.0000 0.3450 0.1241 10.0000 0.0000 1.0000 2 24.1317 180.0000 2.3787 10.0000; #Voce-Chaboche Material

# GEOMETRIC TRANSFORMATIONS IDs
geomTransf Linear 		 1;
geomTransf PDelta 		 2;
geomTransf Corotational 3;
set trans_Linear 	1;
set trans_PDelta 	2;
set trans_Corot  	3;
set trans_selected  2;

# STIFF ELEMENTS PROPERTY
set A_Stiff 1000000.0;
set I_Stiff 10000000000.0;

# COMPOSITE BEAM FACTOR
set Composite 0;
set Comp_I    1.400;
set Comp_I_GC 1.400;

# FIBER ELEMENT PROPERTIES
set nSegments    8;
set initialGI    0.00100;
set nIntegration 5;

# LOGARITHMIC STANDARD DEVIATIONS (FOR UNCERTAINTY CONSIDERATION)
global Sigma_IMKcol Sigma_IMKbeam Sigma_Pinching4 Sigma_PZ; 
set Sigma_IMKcol [list  1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 ];
set Sigma_IMKbeam   [list  1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 ];
set Sigma_Pinching4 [list  1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 1.e-9 ];
set Sigma_PZ        [list  1.e-9 1.e-9 1.e-9 1.e-9 ];
set Sigma_fy     1.e-9;
set Sigma_fyB    1.e-9;
set Sigma_fyG    1.e-9;
set Sigma_GI     1.e-9;
set Sigma_zeta   1.e-9;
global Sigma_fy Sigma_fyB Sigma_fyG Sigma_GI; global xRandom;
set SigmaX $Sigma_fy;  Generate_lognrmrand $fy 	$SigmaX; 	set fy      $xRandom;
set SigmaX $Sigma_fyB; Generate_lognrmrand $fyB 	$SigmaX; 	set fyB 	$xRandom;
set SigmaX $Sigma_fyG; Generate_lognrmrand $fyG 	$SigmaX; 	set fyG 	$xRandom;
set SigmaX $Sigma_GI;  Generate_lognrmrand 0.001000 	    $SigmaX; 	set initialGI 	$xRandom;

####################################################################################################
#                                          PRE-CALCULATIONS                                        #
####################################################################################################

set pi [expr 2.0*asin(1.0)];

# Geometry of Corner Gusset Plate
set   X_CGP1  324.9737;  set   Y_CGP1  495.2600;
set   X_CGP2  325.6484;  set   Y_CGP2  429.8559;
set   X_CGP3  325.6484;  set   Y_CGP3  429.8559;
set   X_CGP4  303.4506;  set   Y_CGP4  400.5547;
set   X_CGP5  293.3299;  set   Y_CGP5  387.1955;
set   X_CGP6  290.1295;  set   Y_CGP6  382.9709;
set   X_CGP7  280.0028;  set   Y_CGP7  369.6037;
set   X_CGP8  276.9050;  set   Y_CGP8  365.5146;
# Geometry of Mid-Span Gusset Plate
set   X_MGP1  275.5221;  set   Y_MGP1  363.6892;
set   X_MGP2  290.5039;  set   Y_MGP2  383.4651;
set   X_MGP3  290.5039;  set   Y_MGP3  383.4651;
set   X_MGP4  290.5039;  set   Y_MGP4  383.4651;
set   X_MGP5  255.5284;  set   Y_MGP5  337.2975;
set   X_MGP6  255.5284;  set   Y_MGP6  337.2975;
set   X_MGP7  249.7193;  set   Y_MGP7  329.6295;
set   X_MGP8  249.7193;  set   Y_MGP8  329.6295;

# FRAME GRID LINES
set Floor9  32292.00;
set Floor8  28332.00;
set Floor7  24372.00;
set Floor6  20412.00;
set Floor5  16452.00;
set Floor4  12492.00;
set Floor3  8532.00;
set Floor2  4572.00;
set Floor1 0.0;

set Axis1 0.0;
set Axis2 6000.00;
set Axis3 12000.00;
set Axis4 18000.00;

set HBuilding 32292.00;
set WFrame 6000.00;
variable HBuilding 32292.00;

####################################################################################################
#                                                  NODES                                           #
####################################################################################################

# COMMAND SYNTAX 
# node $NodeID  $X-Coordinate  $Y-Coordinate;

#SUPPORT NODES
node 110   $Axis1  $Floor1; node 120   $Axis2  $Floor1; node 130   $Axis3  $Floor1; node 140   $Axis4  $Floor1; 

# EGF COLUMN GRID NODES
node 930   $Axis3  $Floor9; node 940   $Axis4  $Floor9; 
node 830   $Axis3  $Floor8; node 840   $Axis4  $Floor8; 
node 730   $Axis3  $Floor7; node 740   $Axis4  $Floor7; 
node 630   $Axis3  $Floor6; node 640   $Axis4  $Floor6; 
node 530   $Axis3  $Floor5; node 540   $Axis4  $Floor5; 
node 430   $Axis3  $Floor4; node 440   $Axis4  $Floor4; 
node 330   $Axis3  $Floor3; node 340   $Axis4  $Floor3; 
node 230   $Axis3  $Floor2; node 240   $Axis4  $Floor2; 

# EGF COLUMN NODES
node 931  $Axis3  $Floor9; node 941  $Axis4  $Floor9; 
node 833  $Axis3  $Floor8; node 843  $Axis4  $Floor8; 
node 831  $Axis3  $Floor8; node 841  $Axis4  $Floor8; 
node 733  $Axis3  $Floor7; node 743  $Axis4  $Floor7; 
node 731  $Axis3  $Floor7; node 741  $Axis4  $Floor7; 
node 633  $Axis3  $Floor6; node 643  $Axis4  $Floor6; 
node 631  $Axis3  $Floor6; node 641  $Axis4  $Floor6; 
node 533  $Axis3  $Floor5; node 543  $Axis4  $Floor5; 
node 531  $Axis3  $Floor5; node 541  $Axis4  $Floor5; 
node 433  $Axis3  $Floor4; node 443  $Axis4  $Floor4; 
node 431  $Axis3  $Floor4; node 441  $Axis4  $Floor4; 
node 333  $Axis3  $Floor3; node 343  $Axis4  $Floor3; 
node 331  $Axis3  $Floor3; node 341  $Axis4  $Floor3; 
node 233  $Axis3  $Floor2; node 243  $Axis4  $Floor2; 
node 231  $Axis3  $Floor2; node 241  $Axis4  $Floor2; 
node 133  $Axis3  $Floor1; node 143  $Axis4  $Floor1; 

# EGF BEAM NODES
node 934  $Axis3  $Floor9; node 942  $Axis4  $Floor9; 
node 834  $Axis3  $Floor8; node 842  $Axis4  $Floor8; 
node 734  $Axis3  $Floor7; node 742  $Axis4  $Floor7; 
node 634  $Axis3  $Floor6; node 642  $Axis4  $Floor6; 
node 534  $Axis3  $Floor5; node 542  $Axis4  $Floor5; 
node 434  $Axis3  $Floor4; node 442  $Axis4  $Floor4; 
node 334  $Axis3  $Floor3; node 342  $Axis4  $Floor3; 
node 234  $Axis3  $Floor2; node 242  $Axis4  $Floor2; 

# MF COLUMN NODES
node 911  $Axis1 [expr $Floor9 - 463.40/2]; node 921  $Axis2 [expr $Floor9 - 463.40/2]; 
node 813  $Axis1 [expr $Floor8 + 463.40/2]; node 823  $Axis2 [expr $Floor8 + 463.40/2]; 
node 811  $Axis1 [expr $Floor8 - 463.40/2]; node 821  $Axis2 [expr $Floor8 - 463.40/2]; 
node 713  $Axis1 [expr $Floor7 + 463.40/2]; node 723  $Axis2 [expr $Floor7 + 463.40/2]; 
node 711  $Axis1 [expr $Floor7 - 463.40/2]; node 721  $Axis2 [expr $Floor7 - 463.40/2]; 
node 613  $Axis1 [expr $Floor6 + 463.40/2]; node 623  $Axis2 [expr $Floor6 + 463.40/2]; 
node 611  $Axis1 [expr $Floor6 - 463.40/2]; node 621  $Axis2 [expr $Floor6 - 463.40/2]; 
node 513  $Axis1 [expr $Floor5 + 539.50/2]; node 523  $Axis2 [expr $Floor5 + 539.50/2]; 
node 511  $Axis1 [expr $Floor5 - 539.50/2]; node 521  $Axis2 [expr $Floor5 - 539.50/2]; 
node 413  $Axis1 [expr $Floor4 + 539.50/2]; node 423  $Axis2 [expr $Floor4 + 539.50/2]; 
node 411  $Axis1 [expr $Floor4 - 539.50/2]; node 421  $Axis2 [expr $Floor4 - 539.50/2]; 
node 313  $Axis1 [expr $Floor3 + 539.50/2]; node 323  $Axis2 [expr $Floor3 + 539.50/2]; 
node 311  $Axis1 [expr $Floor3 - 539.50/2]; node 321  $Axis2 [expr $Floor3 - 539.50/2]; 
node 213  $Axis1 [expr $Floor2 + 539.50/2]; node 223  $Axis2 [expr $Floor2 + 539.50/2]; 
node 211  $Axis1 [expr $Floor2 - 539.50/2]; node 221  $Axis2 [expr $Floor2 - 539.50/2]; 
node 113  $Axis1 $Floor1; node 123  $Axis2 $Floor1; 

# MF BEAM NODES
node 914   [expr $Axis1 + 362.00/2] $Floor9; node 922   [expr $Axis2 - 362.00/2] $Floor9; 
node 814   [expr $Axis1 + 368.20/2] $Floor8; node 822   [expr $Axis2 - 368.20/2] $Floor8; 
node 714   [expr $Axis1 + 368.20/2] $Floor7; node 722   [expr $Axis2 - 368.20/2] $Floor7; 
node 614   [expr $Axis1 + 374.60/2] $Floor6; node 622   [expr $Axis2 - 374.60/2] $Floor6; 
node 514   [expr $Axis1 + 374.60/2] $Floor5; node 522   [expr $Axis2 - 374.60/2] $Floor5; 
node 414   [expr $Axis1 + 419.00/2] $Floor4; node 422   [expr $Axis2 - 419.00/2] $Floor4; 
node 314   [expr $Axis1 + 419.00/2] $Floor3; node 322   [expr $Axis2 - 419.00/2] $Floor3; 
node 214   [expr $Axis1 + 419.00/2] $Floor2; node 222   [expr $Axis2 - 419.00/2] $Floor2; 

# COLUMN SPLICE NODES
node 107172 $Axis1 [expr ($Floor7 + 0.50 * 3960)]; node 107272 $Axis2 [expr ($Floor7 + 0.50 * 3960)]; node 107372 $Axis3 [expr ($Floor7 + 0.50 * 3960)]; node 107472 $Axis4 [expr ($Floor7 + 0.50 * 3960)]; 
node 107171 $Axis1 [expr ($Floor7 + 0.50 * 3960)]; node 107271 $Axis2 [expr ($Floor7 + 0.50 * 3960)]; node 107371 $Axis3 [expr ($Floor7 + 0.50 * 3960)]; node 107471 $Axis4 [expr ($Floor7 + 0.50 * 3960)]; 
node 105172 $Axis1 [expr ($Floor5 + 0.50 * 3960)]; node 105272 $Axis2 [expr ($Floor5 + 0.50 * 3960)]; node 105372 $Axis3 [expr ($Floor5 + 0.50 * 3960)]; node 105472 $Axis4 [expr ($Floor5 + 0.50 * 3960)]; 
node 105171 $Axis1 [expr ($Floor5 + 0.50 * 3960)]; node 105271 $Axis2 [expr ($Floor5 + 0.50 * 3960)]; node 105371 $Axis3 [expr ($Floor5 + 0.50 * 3960)]; node 105471 $Axis4 [expr ($Floor5 + 0.50 * 3960)]; 
node 103172 $Axis1 [expr ($Floor3 + 0.50 * 3960)]; node 103272 $Axis2 [expr ($Floor3 + 0.50 * 3960)]; node 103372 $Axis3 [expr ($Floor3 + 0.50 * 3960)]; node 103472 $Axis4 [expr ($Floor3 + 0.50 * 3960)]; 
node 103171 $Axis1 [expr ($Floor3 + 0.50 * 3960)]; node 103271 $Axis2 [expr ($Floor3 + 0.50 * 3960)]; node 103371 $Axis3 [expr ($Floor3 + 0.50 * 3960)]; node 103471 $Axis4 [expr ($Floor3 + 0.50 * 3960)]; 

# MID-SPAN GUSSET PLATE RIGID OFFSET NODES
node 208101   [expr ($Axis1 + $Axis2)/2] $Floor8;
node 208102   [expr ($Axis1 + $Axis2)/2 - 891.7200/2] $Floor8;
node 208112   [expr ($Axis1 + $Axis2)/2 - 891.7200/2] $Floor8;
node 208105   [expr ($Axis1 + $Axis2)/2 + 891.7200/2] $Floor8;
node 208115   [expr ($Axis1 + $Axis2)/2 + 891.7200/2] $Floor8;
node 208104   [expr ($Axis1 + $Axis2)/2 + $X_MGP7] [expr $Floor8 - $Y_MGP7];
node 208114   [expr ($Axis1 + $Axis2)/2 + $X_MGP7] [expr $Floor8 - $Y_MGP7];
node 208103   [expr ($Axis1 + $Axis2)/2 - $X_MGP7] [expr $Floor8 - $Y_MGP7];
node 208113   [expr ($Axis1 + $Axis2)/2 - $X_MGP7] [expr $Floor8 - $Y_MGP7];
node 208106   [expr ($Axis1 + $Axis2)/2 + $X_MGP8] [expr $Floor8 + $Y_MGP8];
node 208116   [expr ($Axis1 + $Axis2)/2 + $X_MGP8] [expr $Floor8 + $Y_MGP8];
node 208107   [expr ($Axis1 + $Axis2)/2 - $X_MGP8] [expr $Floor8 + $Y_MGP8];
node 208117   [expr ($Axis1 + $Axis2)/2 - $X_MGP8] [expr $Floor8 + $Y_MGP8];
node 206101   [expr ($Axis1 + $Axis2)/2] $Floor6;
node 206102   [expr ($Axis1 + $Axis2)/2 - 1020.3800/2] $Floor6;
node 206112   [expr ($Axis1 + $Axis2)/2 - 1020.3800/2] $Floor6;
node 206105   [expr ($Axis1 + $Axis2)/2 + 1020.3800/2] $Floor6;
node 206115   [expr ($Axis1 + $Axis2)/2 + 1020.3800/2] $Floor6;
node 206104   [expr ($Axis1 + $Axis2)/2 + $X_MGP5] [expr $Floor6 - $Y_MGP5];
node 206114   [expr ($Axis1 + $Axis2)/2 + $X_MGP5] [expr $Floor6 - $Y_MGP5];
node 206103   [expr ($Axis1 + $Axis2)/2 - $X_MGP5] [expr $Floor6 - $Y_MGP5];
node 206113   [expr ($Axis1 + $Axis2)/2 - $X_MGP5] [expr $Floor6 - $Y_MGP5];
node 206106   [expr ($Axis1 + $Axis2)/2 + $X_MGP6] [expr $Floor6 + $Y_MGP6];
node 206116   [expr ($Axis1 + $Axis2)/2 + $X_MGP6] [expr $Floor6 + $Y_MGP6];
node 206107   [expr ($Axis1 + $Axis2)/2 - $X_MGP6] [expr $Floor6 + $Y_MGP6];
node 206117   [expr ($Axis1 + $Axis2)/2 - $X_MGP6] [expr $Floor6 + $Y_MGP6];
node 204101   [expr ($Axis1 + $Axis2)/2] $Floor4;
node 204102   [expr ($Axis1 + $Axis2)/2 - 1249.2900/2] $Floor4;
node 204112   [expr ($Axis1 + $Axis2)/2 - 1249.2900/2] $Floor4;
node 204105   [expr ($Axis1 + $Axis2)/2 + 1249.2900/2] $Floor4;
node 204115   [expr ($Axis1 + $Axis2)/2 + 1249.2900/2] $Floor4;
node 204104   [expr ($Axis1 + $Axis2)/2 + $X_MGP3] [expr $Floor4 - $Y_MGP3];
node 204114   [expr ($Axis1 + $Axis2)/2 + $X_MGP3] [expr $Floor4 - $Y_MGP3];
node 204103   [expr ($Axis1 + $Axis2)/2 - $X_MGP3] [expr $Floor4 - $Y_MGP3];
node 204113   [expr ($Axis1 + $Axis2)/2 - $X_MGP3] [expr $Floor4 - $Y_MGP3];
node 204106   [expr ($Axis1 + $Axis2)/2 + $X_MGP4] [expr $Floor4 + $Y_MGP4];
node 204116   [expr ($Axis1 + $Axis2)/2 + $X_MGP4] [expr $Floor4 + $Y_MGP4];
node 204107   [expr ($Axis1 + $Axis2)/2 - $X_MGP4] [expr $Floor4 + $Y_MGP4];
node 204117   [expr ($Axis1 + $Axis2)/2 - $X_MGP4] [expr $Floor4 + $Y_MGP4];
node 202101   [expr ($Axis1 + $Axis2)/2] $Floor2;
node 202102   [expr ($Axis1 + $Axis2)/2 - 1138.8600/2] $Floor2;
node 202112   [expr ($Axis1 + $Axis2)/2 - 1138.8600/2] $Floor2;
node 202105   [expr ($Axis1 + $Axis2)/2 + 1138.8600/2] $Floor2;
node 202115   [expr ($Axis1 + $Axis2)/2 + 1138.8600/2] $Floor2;
node 202104   [expr ($Axis1 + $Axis2)/2 + $X_MGP1] [expr $Floor2 - $Y_MGP1];
node 202114   [expr ($Axis1 + $Axis2)/2 + $X_MGP1] [expr $Floor2 - $Y_MGP1];
node 202103   [expr ($Axis1 + $Axis2)/2 - $X_MGP1] [expr $Floor2 - $Y_MGP1];
node 202113   [expr ($Axis1 + $Axis2)/2 - $X_MGP1] [expr $Floor2 - $Y_MGP1];
node 202106   [expr ($Axis1 + $Axis2)/2 + $X_MGP2] [expr $Floor2 + $Y_MGP2];
node 202116   [expr ($Axis1 + $Axis2)/2 + $X_MGP2] [expr $Floor2 + $Y_MGP2];
node 202107   [expr ($Axis1 + $Axis2)/2 - $X_MGP2] [expr $Floor2 + $Y_MGP2];
node 202117   [expr ($Axis1 + $Axis2)/2 - $X_MGP2] [expr $Floor2 + $Y_MGP2];

# CORNER X-BRACING RIGID OFFSET NODES
node 109150   [expr $Axis1 + $X_CGP8] [expr $Floor9 - $Y_CGP8];
node 109151   [expr $Axis1 + $X_CGP8] [expr $Floor9 - $Y_CGP8];
node 109250   [expr $Axis2 - $X_CGP8] [expr $Floor9 - $Y_CGP8];
node 109251   [expr $Axis2 - $X_CGP8] [expr $Floor9 - $Y_CGP8];
node 107140   [expr $Axis1 + $X_CGP7] [expr $Floor7 + $Y_CGP7];
node 107141   [expr $Axis1 + $X_CGP7] [expr $Floor7 + $Y_CGP7];
node 107150   [expr $Axis1 + $X_CGP6] [expr $Floor7 - $Y_CGP6];
node 107151   [expr $Axis1 + $X_CGP6] [expr $Floor7 - $Y_CGP6];
node 107240   [expr $Axis2 - $X_CGP7] [expr $Floor7 + $Y_CGP7];
node 107241   [expr $Axis2 - $X_CGP7] [expr $Floor7 + $Y_CGP7];
node 107250   [expr $Axis2 - $X_CGP6] [expr $Floor7 - $Y_CGP6];
node 107251   [expr $Axis2 - $X_CGP6] [expr $Floor7 - $Y_CGP6];
node 105140   [expr $Axis1 + $X_CGP5] [expr $Floor5 + $Y_CGP5];
node 105141   [expr $Axis1 + $X_CGP5] [expr $Floor5 + $Y_CGP5];
node 105150   [expr $Axis1 + $X_CGP4] [expr $Floor5 - $Y_CGP4];
node 105151   [expr $Axis1 + $X_CGP4] [expr $Floor5 - $Y_CGP4];
node 105240   [expr $Axis2 - $X_CGP5] [expr $Floor5 + $Y_CGP5];
node 105241   [expr $Axis2 - $X_CGP5] [expr $Floor5 + $Y_CGP5];
node 105250   [expr $Axis2 - $X_CGP4] [expr $Floor5 - $Y_CGP4];
node 105251   [expr $Axis2 - $X_CGP4] [expr $Floor5 - $Y_CGP4];
node 103140   [expr $Axis1 + $X_CGP3] [expr $Floor3 + $Y_CGP3];
node 103141   [expr $Axis1 + $X_CGP3] [expr $Floor3 + $Y_CGP3];
node 103150   [expr $Axis1 + $X_CGP2] [expr $Floor3 - $Y_CGP2];
node 103151   [expr $Axis1 + $X_CGP2] [expr $Floor3 - $Y_CGP2];
node 103240   [expr $Axis2 - $X_CGP3] [expr $Floor3 + $Y_CGP3];
node 103241   [expr $Axis2 - $X_CGP3] [expr $Floor3 + $Y_CGP3];
node 103250   [expr $Axis2 - $X_CGP2] [expr $Floor3 - $Y_CGP2];
node 103251   [expr $Axis2 - $X_CGP2] [expr $Floor3 - $Y_CGP2];
node 101140   [expr $Axis1 + $X_CGP1] [expr $Floor1 + $Y_CGP1];
node 101141   [expr $Axis1 + $X_CGP1] [expr $Floor1 + $Y_CGP1];
node 101240   [expr $Axis2 - $X_CGP1] [expr $Floor1 + $Y_CGP1];
node 101241   [expr $Axis2 - $X_CGP1] [expr $Floor1 + $Y_CGP1];

###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

# PANEL ZONE NODES AND ELASTIC ELEMENTS
# Command Syntax; 
# ConstructPanel_Rectangle Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag 
ConstructPanel_Rectangle 1 9 $Axis1 $Floor9 $E $A_Stiff $I_Stiff 362.00 463.40 $trans_selected; ConstructPanel_Rectangle 2 9 $Axis2 $Floor9 $E $A_Stiff $I_Stiff 362.00 463.40 $trans_selected; 
ConstructPanel_Rectangle 1 8 $Axis1 $Floor8 $E $A_Stiff $I_Stiff 368.20 463.40 $trans_selected; ConstructPanel_Rectangle 2 8 $Axis2 $Floor8 $E $A_Stiff $I_Stiff 368.20 463.40 $trans_selected; 
ConstructPanel_Rectangle 1 7 $Axis1 $Floor7 $E $A_Stiff $I_Stiff 368.20 463.40 $trans_selected; ConstructPanel_Rectangle 2 7 $Axis2 $Floor7 $E $A_Stiff $I_Stiff 368.20 463.40 $trans_selected; 
ConstructPanel_Rectangle 1 6 $Axis1 $Floor6 $E $A_Stiff $I_Stiff 374.60 463.40 $trans_selected; ConstructPanel_Rectangle 2 6 $Axis2 $Floor6 $E $A_Stiff $I_Stiff 374.60 463.40 $trans_selected; 
ConstructPanel_Rectangle 1 5 $Axis1 $Floor5 $E $A_Stiff $I_Stiff 374.60 539.50 $trans_selected; ConstructPanel_Rectangle 2 5 $Axis2 $Floor5 $E $A_Stiff $I_Stiff 374.60 539.50 $trans_selected; 
ConstructPanel_Rectangle 1 4 $Axis1 $Floor4 $E $A_Stiff $I_Stiff 419.00 539.50 $trans_selected; ConstructPanel_Rectangle 2 4 $Axis2 $Floor4 $E $A_Stiff $I_Stiff 419.00 539.50 $trans_selected; 
ConstructPanel_Rectangle 1 3 $Axis1 $Floor3 $E $A_Stiff $I_Stiff 419.00 539.50 $trans_selected; ConstructPanel_Rectangle 2 3 $Axis2 $Floor3 $E $A_Stiff $I_Stiff 419.00 539.50 $trans_selected; 
ConstructPanel_Rectangle 1 2 $Axis1 $Floor2 $E $A_Stiff $I_Stiff 419.00 539.50 $trans_selected; ConstructPanel_Rectangle 2 2 $Axis2 $Floor2 $E $A_Stiff $I_Stiff 419.00 539.50 $trans_selected; 

####################################################################################################
#                                          PANEL ZONE SPRINGS                                      #
####################################################################################################

# COMMAND SYNTAX 
# Spring_PZ    Element_ID Node_i Node_j E mu fy tw_Col tdp d_Col d_Beam tf_Col bf_Col Ic trib ts Response_ID transfTag
Spring_PZ    909100 409109 409110 $E $mu [expr $fy *   1.0] 12.30   0.00 362.00 463.40 20.70 370.50 485900000.00 88.900 101.600 2 1; Spring_PZ    909200 409209 409210 $E $mu [expr $fy *   1.0] 12.30   0.00 362.00 463.40 20.70 370.50 485900000.00 88.900 101.600 2 1; 
Spring_PZ    908100 408109 408110 $E $mu [expr $fy *   1.0] 12.30   0.00 362.00 463.40 20.70 370.50 485900000.00 88.900 101.600 2 1; Spring_PZ    908200 408209 408210 $E $mu [expr $fy *   1.0] 12.30   0.00 362.00 463.40 20.70 370.50 485900000.00 88.900 101.600 2 1; 
Spring_PZ    907100 407109 407110 $E $mu [expr $fy *   1.0] 14.40   0.00 368.20 463.40 23.80 372.60 571200000.00 88.900 101.600 2 1; Spring_PZ    907200 407209 407210 $E $mu [expr $fy *   1.0] 14.40   0.00 368.20 463.40 23.80 372.60 571200000.00 88.900 101.600 2 1; 
Spring_PZ    906100 406109 406110 $E $mu [expr $fy *   1.0] 14.40   0.00 368.20 463.40 23.80 372.60 571200000.00 88.900 101.600 2 1; Spring_PZ    906200 406209 406210 $E $mu [expr $fy *   1.0] 14.40   0.00 368.20 463.40 23.80 372.60 571200000.00 88.900 101.600 2 1; 
Spring_PZ    905100 405109 405110 $E $mu [expr $fy *   1.0] 16.50   0.00 374.60 539.50 27.00 374.70 662600000.00 88.900 101.600 2 1; Spring_PZ    905200 405209 405210 $E $mu [expr $fy *   1.0] 16.50   0.00 374.60 539.50 27.00 374.70 662600000.00 88.900 101.600 2 1; 
Spring_PZ    904100 404109 404110 $E $mu [expr $fy *   1.0] 16.50   0.00 374.60 539.50 27.00 374.70 662600000.00 88.900 101.600 2 1; Spring_PZ    904200 404209 404210 $E $mu [expr $fy *   1.0] 16.50   0.00 374.60 539.50 27.00 374.70 662600000.00 88.900 101.600 2 1; 
Spring_PZ    903100 403109 403110 $E $mu [expr $fy *   1.0] 30.60   0.00 419.00 539.50 49.20 407.00 1466000000.00 88.900 101.600 2 1; Spring_PZ    903200 403209 403210 $E $mu [expr $fy *   1.0] 30.60   0.00 419.00 539.50 49.20 407.00 1466000000.00 88.900 101.600 2 1; 
Spring_PZ    902100 402109 402110 $E $mu [expr $fy *   1.0] 30.60   0.00 419.00 539.50 49.20 407.00 1466000000.00 88.900 101.600 2 1; Spring_PZ    902200 402209 402210 $E $mu [expr $fy *   1.0] 30.60   0.00 419.00 539.50 49.20 407.00 1466000000.00 88.900 101.600 2 1; 

####################################################################################################
#                                          RIGID BRACE LINKS                                       #
####################################################################################################

# COMMAND SYNTAX 
# element elasticBeamColumn $ElementID $NodeIDi $NodeIDj $Area $E $Inertia $transformation;

# MIDDLE RIGID LINKS

element elasticBeamColumn 708122 208101 208102 $A_Stiff $E $I_Stiff  $trans_selected;
element elasticBeamColumn 708133 208101 208103 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 708144 208101 208104 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 708155 208101 208105 $A_Stiff $E $I_Stiff  $trans_selected;
element elasticBeamColumn 708166 208101 208106 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 708177 208101 208107 $A_Stiff $E $I_Stiff  $trans_Corot;


element elasticBeamColumn 706122 206101 206102 $A_Stiff $E $I_Stiff  $trans_selected;
element elasticBeamColumn 706133 206101 206103 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 706144 206101 206104 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 706155 206101 206105 $A_Stiff $E $I_Stiff  $trans_selected;
element elasticBeamColumn 706166 206101 206106 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 706177 206101 206107 $A_Stiff $E $I_Stiff  $trans_Corot;


element elasticBeamColumn 704122 204101 204102 $A_Stiff $E $I_Stiff  $trans_selected;
element elasticBeamColumn 704133 204101 204103 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 704144 204101 204104 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 704155 204101 204105 $A_Stiff $E $I_Stiff  $trans_selected;
element elasticBeamColumn 704166 204101 204106 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 704177 204101 204107 $A_Stiff $E $I_Stiff  $trans_Corot;


element elasticBeamColumn 702122 202101 202102 $A_Stiff $E $I_Stiff  $trans_selected;
element elasticBeamColumn 702133 202101 202103 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 702144 202101 202104 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 702155 202101 202105 $A_Stiff $E $I_Stiff  $trans_selected;
element elasticBeamColumn 702166 202101 202106 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 702177 202101 202107 $A_Stiff $E $I_Stiff  $trans_Corot;


# CORNER RIGID LINKS
element elasticBeamColumn 709199 409199 109150 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 709299 409206 109250 $A_Stiff $E $I_Stiff  $trans_Corot;

element elasticBeamColumn 707111 407110 107140 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 707199 407199 107150 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 707211 407208 107240 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 707299 407206 107250 $A_Stiff $E $I_Stiff  $trans_Corot;

element elasticBeamColumn 705111 405110 105140 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 705199 405199 105150 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 705211 405208 105240 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 705299 405206 105250 $A_Stiff $E $I_Stiff  $trans_Corot;

element elasticBeamColumn 703111 403110 103140 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 703199 403199 103150 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 703211 403208 103240 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 703299 403206 103250 $A_Stiff $E $I_Stiff  $trans_Corot;

element elasticBeamColumn 701111 110 101140 $A_Stiff $E $I_Stiff  $trans_Corot;
element elasticBeamColumn 701211 120 101240 $A_Stiff $E $I_Stiff  $trans_Corot;


####################################################################################################
#                                 			GUSSET PLATE SPRINGS   		                            #
####################################################################################################

# COMMAND SYNTAX 
# Spring_Gusset $SpringID $NodeIDi $NodeIDj $E $fy $L_buckling $t_plate $L_connection $d_brace $MatID;

# BEAM MID-SPAN GUSSET PLATE SPRING
Spring_Gusset 908133 208113 208103 $E $fyG 123.1067 16.0000 175.0000 5.0000  4000;
Spring_Gusset 908144 208114 208104 $E $fyG 123.1067 16.0000 175.0000 5.0000  4001;
Spring_Gusset 908166 208116 208106 $E $fyG 123.1067 16.0000 175.0000 5.0000  4002;
Spring_Gusset 908177 208117 208107 $E $fyG 123.1067 16.0000 175.0000 5.0000  4003;

Spring_Gusset 906133 206113 206103 $E $fyG 132.7300 16.0000 255.0000 6.0000  4004;
Spring_Gusset 906144 206114 206104 $E $fyG 132.7300 16.0000 255.0000 6.0000  4005;
Spring_Gusset 906166 206116 206106 $E $fyG 132.7300 16.0000 255.0000 6.0000  4006;
Spring_Gusset 906177 206117 206107 $E $fyG 132.7300 16.0000 255.0000 6.0000  4007;

Spring_Gusset 904133 204113 204103 $E $fyG 142.3500 16.0000 370.0000 7.0000  4008;
Spring_Gusset 904144 204114 204104 $E $fyG 142.3500 16.0000 370.0000 7.0000  4009;
Spring_Gusset 904166 204116 204106 $E $fyG 142.3500 16.0000 370.0000 7.0000  4010;
Spring_Gusset 904177 204117 204107 $E $fyG 142.3500 16.0000 370.0000 7.0000  4011;

Spring_Gusset 902133 202113 202103 $E $fyG 133.3333 16.0000 370.0000 7.0000  4012;
Spring_Gusset 902144 202114 202104 $E $fyG 133.3333 16.0000 370.0000 7.0000  4013;
Spring_Gusset 902166 202116 202106 $E $fyG 142.3500 16.0000 370.0000 7.0000  4014;
Spring_Gusset 902177 202117 202107 $E $fyG 142.3500 16.0000 370.0000 7.0000  4015;


# CORNER GUSSET PLATE SPRINGS
Spring_Gusset 909199 109150 109151 $E $fyG 49.6867 16.0000 175.0000 5.0000  4016;
Spring_Gusset 909299 109250 109251 $E $fyG 49.6867 16.0000 175.0000 5.0000  4017;

Spring_Gusset 907111 107140 107141 $E $fyG 49.6867 16.0000 175.0000 5.0000  4018;
Spring_Gusset 907199 107150 107151 $E $fyG 11.8233 16.0000 255.0000 6.0000  4019;
Spring_Gusset 907211 107240 107241 $E $fyG 49.6867 16.0000 175.0000 5.0000  4020;
Spring_Gusset 907299 107250 107251 $E $fyG 11.8233 16.0000 255.0000 6.0000  4021;

Spring_Gusset 905111 105140 105141 $E $fyG 18.5833 16.0000 255.0000 6.0000  4022;
Spring_Gusset 905199 105150 105151 $E $fyG -36.3467 16.0000 370.0000 7.0000  4023;
Spring_Gusset 905211 105240 105241 $E $fyG 18.5833 16.0000 255.0000 6.0000  4024;
Spring_Gusset 905299 105250 105251 $E $fyG -36.3467 16.0000 370.0000 7.0000  4025;

Spring_Gusset 903111 103140 103141 $E $fyG -14.4233 16.0000 370.0000 7.0000  4026;
Spring_Gusset 903199 103150 103151 $E $fyG -14.4233 16.0000 370.0000 7.0000  4027;
Spring_Gusset 903211 103240 103241 $E $fyG -14.4233 16.0000 370.0000 7.0000  4028;
Spring_Gusset 903299 103250 103251 $E $fyG -14.4233 16.0000 370.0000 7.0000  4029;

Spring_Gusset 901111 101140 101141 $E $fyG 117.9267 16.0000 370.0000 7.0000  4030;
Spring_Gusset 901211 101240 101241 $E $fyG 117.9267 16.0000 370.0000 7.0000  4031;


####################################################################################################
#                                 BRACE MEMBERS WITH FATIGUE MATERIAL                              #
####################################################################################################

# CREATE FATIGUE MATERIALS
# COMMAND SYNTAX 
# FatigueMat $MatID $BraceSecType $fy $E $L_brace $ry_brace $ht_brace $htw_brace $bftf_brace;
FatigueMat 100 1 $fyB $E 4419.7500 66.8020 12.1000  0.0 0.0;
FatigueMat 102 1 $fyB $E 3947.6900 66.8020 12.1000  0.0 0.0;
FatigueMat 104 1 $fyB $E 3947.6900 66.8020 12.1000  0.0 0.0;
FatigueMat 106 1 $fyB $E 3984.4600 66.8020 12.1000  0.0 0.0;
FatigueMat 108 1 $fyB $E 4059.1400 56.6420 9.9000  0.0 0.0;
FatigueMat 110 1 $fyB $E 4064.4400 56.6420 9.9000  0.0 0.0;
FatigueMat 112 1 $fyB $E 4090.8300 46.2280 7.7500  0.0 0.0;
FatigueMat 114 1 $fyB $E 4095.9600 46.2280 7.7500  0.0 0.0;

# CREATE THE BRACE SECTIONS
# COMMAND SYNTAX 
# FiberRHSS $BraceSecType $FatigueMatID $h_brace $t_brace $nFiber $nFiber $nFiber $nFiber;
FiberRHSS     1   101 7.0000 0.5000 10 4 10 4; 
FiberRHSS     2   103 7.0000 0.5000 10 4 10 4; 
FiberRHSS     3   105 7.0000 0.5000 10 4 10 4; 
FiberRHSS     4   107 7.0000 0.5000 10 4 10 4; 
FiberRHSS     5   109 6.0000 0.5000 10 4 10 4; 
FiberRHSS     6   111 6.0000 0.5000 10 4 10 4; 
FiberRHSS     7   113 5.0000 0.5000 10 4 10 4; 
FiberRHSS     8   115 5.0000 0.5000 10 4 10 4; 

# CONSTRUCT THE BRACE MEMBERS
# COMMAND SYNTAX 
# ConstructBrace $BraceID $NodeIDi $NodeIDj $nSegments $Imperfeection $nIntgeration $transformation;
ConstructBrace 8101100   101141   202113     1   $nSegments $initialGI $nIntegration  $trans_Corot;
ConstructBrace 8201100   101241   202114     1   $nSegments $initialGI $nIntegration  $trans_Corot;

ConstructBrace 8102100   103151   202117     2   $nSegments $initialGI $nIntegration  $trans_Corot;
ConstructBrace 8202100   103251   202116     2   $nSegments $initialGI $nIntegration  $trans_Corot;

ConstructBrace 8103100   103141   204113     3   $nSegments $initialGI $nIntegration  $trans_Corot;
ConstructBrace 8203100   103241   204114     3   $nSegments $initialGI $nIntegration  $trans_Corot;

ConstructBrace 8104100   105151   204117     4   $nSegments $initialGI $nIntegration  $trans_Corot;
ConstructBrace 8204100   105251   204116     4   $nSegments $initialGI $nIntegration  $trans_Corot;

ConstructBrace 8105100   105141   206113     5   $nSegments $initialGI $nIntegration  $trans_Corot;
ConstructBrace 8205100   105241   206114     5   $nSegments $initialGI $nIntegration  $trans_Corot;

ConstructBrace 8106100   107151   206117     6   $nSegments $initialGI $nIntegration  $trans_Corot;
ConstructBrace 8206100   107251   206116     6   $nSegments $initialGI $nIntegration  $trans_Corot;

ConstructBrace 8107100   107141   208113     7   $nSegments $initialGI $nIntegration  $trans_Corot;
ConstructBrace 8207100   107241   208114     7   $nSegments $initialGI $nIntegration  $trans_Corot;

ConstructBrace 8108100   109151   208117     8   $nSegments $initialGI $nIntegration  $trans_Corot;
ConstructBrace 8208100   109251   208116     8   $nSegments $initialGI $nIntegration  $trans_Corot;


# CONSTRUCT THE GHOST BRACES
uniaxialMaterial Elastic 1000 100.0
element corotTruss 4101100   101141   202113  0.05  1000;
element corotTruss 4201100   101241   202114  0.05  1000;
element corotTruss 4102100   103151   202117  0.05  1000;
element corotTruss 4202100   103251   202116  0.05  1000;
element corotTruss 4103100   103141   204113  0.05  1000;
element corotTruss 4203100   103241   204114  0.05  1000;
element corotTruss 4104100   105151   204117  0.05  1000;
element corotTruss 4204100   105251   204116  0.05  1000;
element corotTruss 4105100   105141   206113  0.05  1000;
element corotTruss 4205100   105241   206114  0.05  1000;
element corotTruss 4106100   107151   206117  0.05  1000;
element corotTruss 4206100   107251   206116  0.05  1000;
element corotTruss 4107100   107141   208113  0.05  1000;
element corotTruss 4207100   107241   208114  0.05  1000;
element corotTruss 4108100   109151   208117  0.05  1000;
element corotTruss 4208100   109251   208116  0.05  1000;

####################################################################################################
#                                     ELASTIC COLUMNS AND BEAMS                                    #
####################################################################################################

# COMMAND SYNTAX 
# element ModElasticBeam2d $ElementID $iNode $jNode $Area $E $Ix $K11 $K33 $K44 $transformation 

# STIFFNESS MODIFIERS
set n 10.;
set K44_2 [expr 6*(1+$n)/(2+3*$n)];
set K11_2 [expr (1+2*$n)*$K44_2/(1+$n)];
set K33_2 [expr (1+2*$n)*$K44_2/(1+$n)];
set K44_1 [expr 6*$n/(1+3*$n)];
set K11_1 [expr (1+2*$n)*$K44_1/(1+$n)];
set K33_1 [expr 2*$K44_1];

# COLUMNS
element ModElasticBeam2d   608100      813      911  19480.0000 $E [expr ($n+1)/$n*485900000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   608200      823      921  19480.0000 $E [expr ($n+1)/$n*485900000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   607102   107172      811 19480.0000 $E [expr ($n+1)/$n*485900000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  element ModElasticBeam2d   607202   107272      821 19480.0000 $E [expr ($n+1)/$n*485900000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  
element ModElasticBeam2d   607101      713   107171 22550.0000 $E [expr ($n+1)/$n*571200000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  element ModElasticBeam2d   607201      723   107271 22550.0000 $E [expr ($n+1)/$n*571200000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  
element ModElasticBeam2d   606100      613      711  22550.0000 $E [expr ($n+1)/$n*571200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   606200      623      721  22550.0000 $E [expr ($n+1)/$n*571200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   605102   105172      611 22550.0000 $E [expr ($n+1)/$n*571200000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  element ModElasticBeam2d   605202   105272      621 22550.0000 $E [expr ($n+1)/$n*571200000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  
element ModElasticBeam2d   605101      513   105171 25720.0000 $E [expr ($n+1)/$n*662600000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  element ModElasticBeam2d   605201      523   105271 25720.0000 $E [expr ($n+1)/$n*662600000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  
element ModElasticBeam2d   604100      413      511  25720.0000 $E [expr ($n+1)/$n*662600000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   604200      423      521  25720.0000 $E [expr ($n+1)/$n*662600000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   603102   103172      411 25720.0000 $E [expr ($n+1)/$n*662600000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  element ModElasticBeam2d   603202   103272      421 25720.0000 $E [expr ($n+1)/$n*662600000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  
element ModElasticBeam2d   603101      313   103171 50060.0000 $E [expr ($n+1)/$n*1466000000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  element ModElasticBeam2d   603201      323   103271 50060.0000 $E [expr ($n+1)/$n*1466000000.0000] $K33_1 $K11_1 $K44_1 $trans_selected;  
element ModElasticBeam2d   602100      213      311  50060.0000 $E [expr ($n+1)/$n*1466000000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   602200      223      321  50060.0000 $E [expr ($n+1)/$n*1466000000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   601100      113      211  50060.0000 $E [expr ($n+1)/$n*1466000000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   601200      123      221  50060.0000 $E [expr ($n+1)/$n*1466000000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 

# BEAMS
element ModElasticBeam2d   509100      914      922  11380.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*410200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   508101      814   208112  11380.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*410200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   508102      822   208115  11380.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*410200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   507100      714      722  11380.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*410200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   506101      614   206112  11380.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*410200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   506102      622   206115  11380.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*410200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   505100      514      522  13890.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*668200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   504101      414   204112  13890.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*668200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   504102      422   204115  13890.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*668200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   503100      314      322  13890.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*668200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   502101      214   202112  13890.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*668200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   502102      222   202115  13890.0000 $E [expr ($n+1)/$n*0.90*$Comp_I*668200000.0000] $K11_2 $K33_2 $K44_2 $trans_selected; 

###################################################################################################
#                                           MF BEAM SPRINGS                                       #
###################################################################################################

Spring_IMK 908104 408104 814 $E $fy [expr $Comp_I*410200000.0000]  463.4000 38.8571 5.4209 42.9000 2370.0400 1185.0200 1185.0200 764313.0000 0 $Composite 0 1; Spring_IMK 908202 822 408202 $E $fy [expr $Comp_I*410200000.0000]  463.4000 38.8571 5.4209 42.9000 2370.0400 1185.0200 1185.0200 764313.0000 0 $Composite 0 1; Spring_IMK 908122 208112 208102 $E $fy [expr $Comp_I*410200000.0000] 463.4000 38.8571 5.4209 42.9000 2370.0400 1185.0200 1185.0200 764313.0000 0 $Composite 0 1; Spring_IMK 908155 208105 208115 $E $fy [expr $Comp_I*410200000.0000] 463.4000 38.8571 5.4209 42.9000 2370.0400 1185.0200 1185.0200 764313.0000 0 $Composite 0 1; 
Spring_IMK 906104 406104 614 $E $fy [expr $Comp_I*410200000.0000]  463.4000 38.8571 5.4209 42.9000 2302.5100 1151.2550 1151.2550 764313.0000 0 $Composite 0 1; Spring_IMK 906202 622 406202 $E $fy [expr $Comp_I*410200000.0000]  463.4000 38.8571 5.4209 42.9000 2302.5100 1151.2550 1151.2550 764313.0000 0 $Composite 0 1; Spring_IMK 906122 206112 206102 $E $fy [expr $Comp_I*410200000.0000] 463.4000 38.8571 5.4209 42.9000 2302.5100 1151.2550 1151.2550 764313.0000 0 $Composite 0 1; Spring_IMK 906155 206105 206115 $E $fy [expr $Comp_I*410200000.0000] 463.4000 38.8571 5.4209 42.9000 2302.5100 1151.2550 1151.2550 764313.0000 0 $Composite 0 1; 
Spring_IMK 904104 404104 414 $E $fy [expr $Comp_I*668200000.0000]  539.5000 41.0259 5.6064 46.0000 2165.8550 1082.9275 1082.9275 1073226.0000 0 $Composite 0 1; Spring_IMK 904202 422 404202 $E $fy [expr $Comp_I*668200000.0000]  539.5000 41.0259 5.6064 46.0000 2165.8550 1082.9275 1082.9275 1073226.0000 0 $Composite 0 1; Spring_IMK 904122 204112 204102 $E $fy [expr $Comp_I*668200000.0000] 539.5000 41.0259 5.6064 46.0000 2165.8550 1082.9275 1082.9275 1073226.0000 0 $Composite 0 1; Spring_IMK 904155 204105 204115 $E $fy [expr $Comp_I*668200000.0000] 539.5000 41.0259 5.6064 46.0000 2165.8550 1082.9275 1082.9275 1073226.0000 0 $Composite 0 1; 
Spring_IMK 902104 402104 214 $E $fy [expr $Comp_I*668200000.0000]  539.5000 41.0259 5.6064 46.0000 2221.0700 1110.5350 1110.5350 1073226.0000 0 $Composite 0 1; Spring_IMK 902202 222 402202 $E $fy [expr $Comp_I*668200000.0000]  539.5000 41.0259 5.6064 46.0000 2221.0700 1110.5350 1110.5350 1073226.0000 0 $Composite 0 1; Spring_IMK 902122 202112 202102 $E $fy [expr $Comp_I*668200000.0000] 539.5000 41.0259 5.6064 46.0000 2221.0700 1110.5350 1110.5350 1073226.0000 0 $Composite 0 1; Spring_IMK 902155 202105 202115 $E $fy [expr $Comp_I*668200000.0000] 539.5000 41.0259 5.6064 46.0000 2221.0700 1110.5350 1110.5350 1073226.0000 0 $Composite 0 1; 

Spring_IMK 909104 409104 914 $E $fy [expr $Comp_I*410200000.0000] 463.4000 38.8571 5.4209 42.9000 5638.0000 2819.0000 2819.0000 764313.0000 0 $Composite 0 1; Spring_IMK 909202 922 409202 $E $fy [expr $Comp_I*410200000.0000] 463.4000 38.8571 5.4209 42.9000 5638.0000 2819.0000 2819.0000 764313.0000 0 $Composite 0 1; 
Spring_IMK 907104 407104 714 $E $fy [expr $Comp_I*410200000.0000] 463.4000 38.8571 5.4209 42.9000 5631.8000 2815.9000 2815.9000 764313.0000 0 $Composite 0 1; Spring_IMK 907202 722 407202 $E $fy [expr $Comp_I*410200000.0000] 463.4000 38.8571 5.4209 42.9000 5631.8000 2815.9000 2815.9000 764313.0000 0 $Composite 0 1; 
Spring_IMK 905104 405104 514 $E $fy [expr $Comp_I*668200000.0000] 539.5000 41.0259 5.6064 46.0000 5625.4000 2812.7000 2812.7000 1073226.0000 0 $Composite 0 1; Spring_IMK 905202 522 405202 $E $fy [expr $Comp_I*668200000.0000] 539.5000 41.0259 5.6064 46.0000 5625.4000 2812.7000 2812.7000 1073226.0000 0 $Composite 0 1; 
Spring_IMK 903104 403104 314 $E $fy [expr $Comp_I*668200000.0000] 539.5000 41.0259 5.6064 46.0000 5581.0000 2790.5000 2790.5000 1073226.0000 0 $Composite 0 1; Spring_IMK 903202 322 403202 $E $fy [expr $Comp_I*668200000.0000] 539.5000 41.0259 5.6064 46.0000 5581.0000 2790.5000 2790.5000 1073226.0000 0 $Composite 0 1; 

###################################################################################################
#                                           MF COLUMN SPRINGS                                     #
###################################################################################################

Spring_IMK  909101  409101     911 $E $fy 485900000.0000 362.0000 23.5772 8.9493 94.9000 3496.6000 1748.3000 3496.6000 1125217.5000 0.0193  0 0 1; Spring_IMK  909201  409201     921 $E $fy 485900000.0000 362.0000 23.5772 8.9493 94.9000 3496.6000 1748.3000 3496.6000 1125217.5000 0.0193  0 0 1; 
Spring_IMK  908103  408103     813 $E $fy 485900000.0000 362.0000 23.5772 8.9493 94.9000 3496.6000 1748.3000 3496.6000 1125217.5000 0.0193  0 0 1; Spring_IMK  908203  408203     823 $E $fy 485900000.0000 362.0000 23.5772 8.9493 94.9000 3496.6000 1748.3000 3496.6000 1125217.5000 0.0193  0 0 1; 
Spring_IMK  908101  408101     811 $E $fy 485900000.0000 362.0000 23.5772 8.9493 94.9000 3496.6000 1748.3000 3496.6000 1125217.5000 0.0415  0 0 1; Spring_IMK  908201  408201     821 $E $fy 485900000.0000 362.0000 23.5772 8.9493 94.9000 3496.6000 1748.3000 3496.6000 1125217.5000 0.0415  0 0 1; 
Spring_IMK  907103  407103     713 $E $fy 571200000.0000 368.2000 20.1389 7.8277 95.4000 3496.6000 1748.3000 3496.6000 1311172.5000 0.0358  0 0 1; Spring_IMK  907203  407203     723 $E $fy 571200000.0000 368.2000 20.1389 7.8277 95.4000 3496.6000 1748.3000 3496.6000 1311172.5000 0.0358  0 0 1; 
Spring_IMK  907101  407101     711 $E $fy 571200000.0000 368.2000 20.1389 7.8277 95.4000 3496.6000 1748.3000 3496.6000 1311172.5000 0.0550  0 0 1; Spring_IMK  907201  407201     721 $E $fy 571200000.0000 368.2000 20.1389 7.8277 95.4000 3496.6000 1748.3000 3496.6000 1311172.5000 0.0550  0 0 1; 
Spring_IMK  906103  406103     613 $E $fy 571200000.0000 368.2000 20.1389 7.8277 95.4000 3496.6000 1748.3000 3496.6000 1311172.5000 0.0550  0 0 1; Spring_IMK  906203  406203     623 $E $fy 571200000.0000 368.2000 20.1389 7.8277 95.4000 3496.6000 1748.3000 3496.6000 1311172.5000 0.0550  0 0 1; 
Spring_IMK  906101  406101     611 $E $fy 571200000.0000 368.2000 20.1389 7.8277 95.4000 3496.6000 1748.3000 3496.6000 1311172.5000 0.0741  0 0 1; Spring_IMK  906201  406201     621 $E $fy 571200000.0000 368.2000 20.1389 7.8277 95.4000 3496.6000 1748.3000 3496.6000 1311172.5000 0.0741  0 0 1; 
Spring_IMK  905103  405103     513 $E $fy 662600000.0000 374.6000 17.5758 6.9389 96.0000 3458.5500 1729.2750 3458.5500 1507374.0000 0.0650  0 0 1; Spring_IMK  905203  405203     523 $E $fy 662600000.0000 374.6000 17.5758 6.9389 96.0000 3458.5500 1729.2750 3458.5500 1507374.0000 0.0650  0 0 1; 
Spring_IMK  905101  405101     511 $E $fy 662600000.0000 374.6000 17.5758 6.9389 96.0000 3420.5000 1710.2500 3420.5000 1507374.0000 0.0817  0 0 1; Spring_IMK  905201  405201     521 $E $fy 662600000.0000 374.6000 17.5758 6.9389 96.0000 3420.5000 1710.2500 3420.5000 1507374.0000 0.0817  0 0 1; 
Spring_IMK  904103  404103     413 $E $fy 662600000.0000 374.6000 17.5758 6.9389 96.0000 3420.5000 1710.2500 3420.5000 1507374.0000 0.0817  0 0 1; Spring_IMK  904203  404203     423 $E $fy 662600000.0000 374.6000 17.5758 6.9389 96.0000 3420.5000 1710.2500 3420.5000 1507374.0000 0.0817  0 0 1; 
Spring_IMK  904101  404101     411 $E $fy 662600000.0000 374.6000 17.5758 6.9389 96.0000 3420.5000 1710.2500 3420.5000 1507374.0000 0.0985  0 0 1; Spring_IMK  904201  404201     421 $E $fy 662600000.0000 374.6000 17.5758 6.9389 96.0000 3420.5000 1710.2500 3420.5000 1507374.0000 0.0985  0 0 1; 
Spring_IMK  903103  403103     313 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 3420.5000 1710.2500 3420.5000 3120249.0000 0.0506  0 0 1; Spring_IMK  903203  403203     323 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 3420.5000 1710.2500 3420.5000 3120249.0000 0.0506  0 0 1; 
Spring_IMK  903101  403101     311 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 3420.5000 1710.2500 3420.5000 3120249.0000 0.0592  0 0 1; Spring_IMK  903201  403201     321 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 3420.5000 1710.2500 3420.5000 3120249.0000 0.0592  0 0 1; 
Spring_IMK  902103  402103     213 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 3420.5000 1710.2500 3420.5000 3120249.0000 0.0592  0 0 1; Spring_IMK  902203  402203     223 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 3420.5000 1710.2500 3420.5000 3120249.0000 0.0592  0 0 1; 
Spring_IMK  902101  402101     211 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 4302.2500 2151.1250 4302.2500 3120249.0000 0.0680  0 0 1; Spring_IMK  902201  402201     221 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 4302.2500 2151.1250 4302.2500 3120249.0000 0.0680  0 0 1; 
Spring_IMK  901103     110     113 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 4302.2500 2151.1250 4302.2500 3120249.0000 0.0680  0 0 1; Spring_IMK  901203     120     123 $E $fy 1466000000.0000 419.0000 9.4771 4.1362 105.2000 4302.2500 2151.1250 4302.2500 3120249.0000 0.0680  0 0 1; 

###################################################################################################
#                                          COLUMN SPLICE SPRINGS                                  #
###################################################################################################

Spring_Rigid 907107 107171 107172; 
Spring_Rigid 907207 107271 107272; 
Spring_Rigid 907307 107371 107372; 
Spring_Rigid 907407 107471 107472; 
Spring_Rigid 905107 105171 105172; 
Spring_Rigid 905207 105271 105272; 
Spring_Rigid 905307 105371 105372; 
Spring_Rigid 905407 105471 105472; 
Spring_Rigid 903107 103171 103172; 
Spring_Rigid 903207 103271 103272; 
Spring_Rigid 903307 103371 103372; 
Spring_Rigid 903407 103471 103472; 

####################################################################################################
#                                              FLOOR LINKS                                         #
####################################################################################################

# Command Syntax 
# element truss $ElementID $iNode $jNode $Area $matID
element truss 1009 409204 930 $A_Stiff 99;
element truss 1008 408204 830 $A_Stiff 99;
element truss 1007 407204 730 $A_Stiff 99;
element truss 1006 406204 630 $A_Stiff 99;
element truss 1005 405204 530 $A_Stiff 99;
element truss 1004 404204 430 $A_Stiff 99;
element truss 1003 403204 330 $A_Stiff 99;
element truss 1002 402204 230 $A_Stiff 99;

####################################################################################################
#                                          EGF COLUMNS AND BEAMS                                   #
####################################################################################################

# GRAVITY COLUMNS
element elasticBeamColumn  608300     833     931 34880.0000 $E [expr (214000000.0000  + 351000000.0000)] $trans_PDelta; element elasticBeamColumn  608400     843     941 34880.0000 $E [expr (214000000.0000  + 351000000.0000)] $trans_PDelta; 
element elasticBeamColumn  607302  107372     831 34880.0000 $E [expr (214000000.0000  + 351000000.0000)] $trans_PDelta; element elasticBeamColumn  607402  107472     841 34880.0000 $E [expr (214000000.0000  + 351000000.0000)] $trans_PDelta; 
element elasticBeamColumn  607301     733  107371 34880.0000 $E [expr (214000000.0000  + 410600000.0000)] $trans_PDelta; element elasticBeamColumn  607401     743  107471 34880.0000 $E [expr (214000000.0000  + 410600000.0000)] $trans_PDelta; 
element elasticBeamColumn  606300     633     731 34880.0000 $E [expr (214000000.0000  + 410600000.0000)] $trans_PDelta; element elasticBeamColumn  606400     643     741 34880.0000 $E [expr (214000000.0000  + 410600000.0000)] $trans_PDelta; 
element elasticBeamColumn  605302  105372     631 34880.0000 $E [expr (214000000.0000  + 410600000.0000)] $trans_PDelta; element elasticBeamColumn  605402  105472     641 34880.0000 $E [expr (214000000.0000  + 410600000.0000)] $trans_PDelta; 
element elasticBeamColumn  605301     533  105371 34880.0000 $E [expr (214000000.0000  + 473800000.0000)] $trans_PDelta; element elasticBeamColumn  605401     543  105471 34880.0000 $E [expr (214000000.0000  + 473800000.0000)] $trans_PDelta; 
element elasticBeamColumn  604300     433     531 34880.0000 $E [expr (214000000.0000  + 473800000.0000)] $trans_PDelta; element elasticBeamColumn  604400     443     541 34880.0000 $E [expr (214000000.0000  + 473800000.0000)] $trans_PDelta; 
element elasticBeamColumn  603302  103372     431 34880.0000 $E [expr (214000000.0000  + 473800000.0000)] $trans_PDelta; element elasticBeamColumn  603402  103472     441 34880.0000 $E [expr (214000000.0000  + 473800000.0000)] $trans_PDelta; 
element elasticBeamColumn  603301     333  103371 34880.0000 $E [expr (214000000.0000  + 1107400000.0000)] $trans_PDelta; element elasticBeamColumn  603401     343  103471 34880.0000 $E [expr (214000000.0000  + 1107400000.0000)] $trans_PDelta; 
element elasticBeamColumn  602300     233     331 34880.0000 $E [expr (214000000.0000  + 1107400000.0000)] $trans_PDelta; element elasticBeamColumn  602400     243     341 34880.0000 $E [expr (214000000.0000  + 1107400000.0000)] $trans_PDelta; 
element elasticBeamColumn  601300     133     231 34880.0000 $E [expr (214000000.0000  + 1107400000.0000)] $trans_PDelta; element elasticBeamColumn  601400     143     241 34880.0000 $E [expr (214000000.0000  + 1107400000.0000)] $trans_PDelta; 

# GRAVITY BEAMS
element elasticBeamColumn  509200     934     942 22410.0000 $E [expr $Comp_I_GC * 457650000.0000] $trans_PDelta;
element elasticBeamColumn  508200     834     842 22410.0000 $E [expr $Comp_I_GC * 457650000.0000] $trans_PDelta;
element elasticBeamColumn  507200     734     742 22410.0000 $E [expr $Comp_I_GC * 457650000.0000] $trans_PDelta;
element elasticBeamColumn  506200     634     642 22410.0000 $E [expr $Comp_I_GC * 457650000.0000] $trans_PDelta;
element elasticBeamColumn  505200     534     542 22410.0000 $E [expr $Comp_I_GC * 457650000.0000] $trans_PDelta;
element elasticBeamColumn  504200     434     442 22410.0000 $E [expr $Comp_I_GC * 457650000.0000] $trans_PDelta;
element elasticBeamColumn  503200     334     342 22410.0000 $E [expr $Comp_I_GC * 457650000.0000] $trans_PDelta;
element elasticBeamColumn  502200     234     242 22410.0000 $E [expr $Comp_I_GC * 457650000.0000] $trans_PDelta;

# GRAVITY COLUMNS SPRINGS
Spring_IMK   909301     930     931 $E $fy [expr (214000000.0000 + 351000000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 1888392.0000 0 $Composite 0 1; Spring_IMK   909401     940     941 $E $fy [expr (214000000.0000 + 351000000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 1888392.0000 0 $Composite 0 1; 
Spring_IMK   908303     830     833 $E $fy [expr (214000000.0000 + 351000000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 1888392.0000 0 $Composite 0 1; Spring_IMK   908403     840     843 $E $fy [expr (214000000.0000 + 351000000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 1888392.0000 0 $Composite 0 1; 
Spring_IMK   908301     830     831 $E $fy [expr (214000000.0000 + 351000000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 1888392.0000 0 $Composite 0 1; Spring_IMK   908401     840     841 $E $fy [expr (214000000.0000 + 351000000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 1888392.0000 0 $Composite 0 1; 
Spring_IMK   907303     730     733 $E $fy [expr (214000000.0000 + 410600000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2067516.0000 0 $Composite 0 1; Spring_IMK   907403     740     743 $E $fy [expr (214000000.0000 + 410600000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2067516.0000 0 $Composite 0 1; 
Spring_IMK   907301     730     731 $E $fy [expr (214000000.0000 + 410600000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2067516.0000 0 $Composite 0 1; Spring_IMK   907401     740     741 $E $fy [expr (214000000.0000 + 410600000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2067516.0000 0 $Composite 0 1; 
Spring_IMK   906303     630     633 $E $fy [expr (214000000.0000 + 410600000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2067516.0000 0 $Composite 0 1; Spring_IMK   906403     640     643 $E $fy [expr (214000000.0000 + 410600000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2067516.0000 0 $Composite 0 1; 
Spring_IMK   906301     630     631 $E $fy [expr (214000000.0000 + 410600000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2067516.0000 0 $Composite 0 1; Spring_IMK   906401     640     641 $E $fy [expr (214000000.0000 + 410600000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2067516.0000 0 $Composite 0 1; 
Spring_IMK   905303     530     533 $E $fy [expr (214000000.0000 + 473800000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2256507.0000 0 $Composite 0 1; Spring_IMK   905403     540     543 $E $fy [expr (214000000.0000 + 473800000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2256507.0000 0 $Composite 0 1; 
Spring_IMK   905301     530     531 $E $fy [expr (214000000.0000 + 473800000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2256507.0000 0 $Composite 0 1; Spring_IMK   905401     540     541 $E $fy [expr (214000000.0000 + 473800000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2256507.0000 0 $Composite 0 1; 
Spring_IMK   904303     430     433 $E $fy [expr (214000000.0000 + 473800000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2256507.0000 0 $Composite 0 1; Spring_IMK   904403     440     443 $E $fy [expr (214000000.0000 + 473800000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2256507.0000 0 $Composite 0 1; 
Spring_IMK   904301     430     431 $E $fy [expr (214000000.0000 + 473800000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2256507.0000 0 $Composite 0 1; Spring_IMK   904401     440     441 $E $fy [expr (214000000.0000 + 473800000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 2256507.0000 0 $Composite 0 1; 
Spring_IMK   903303     330     333 $E $fy [expr (214000000.0000 + 1107400000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 3952113.0000 0 $Composite 0 1; Spring_IMK   903403     340     343 $E $fy [expr (214000000.0000 + 1107400000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 3952113.0000 0 $Composite 0 1; 
Spring_IMK   903301     330     331 $E $fy [expr (214000000.0000 + 1107400000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 3952113.0000 0 $Composite 0 1; Spring_IMK   903401     340     341 $E $fy [expr (214000000.0000 + 1107400000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 3952113.0000 0 $Composite 0 1; 
Spring_IMK   902303     230     233 $E $fy [expr (214000000.0000 + 1107400000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 3952113.0000 0 $Composite 0 1; Spring_IMK   902403     240     243 $E $fy [expr (214000000.0000 + 1107400000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 3952113.0000 0 $Composite 0 1; 
Spring_IMK   902301     230     231 $E $fy [expr (214000000.0000 + 1107400000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 3952113.0000 0 $Composite 0 1; Spring_IMK   902401     240     241 $E $fy [expr (214000000.0000 + 1107400000.0000)] 320.5000 17.9058 7.1244 78.3000 3960.0000 1980.0000 3960.0000 3952113.0000 0 $Composite 0 1; 
Spring_IMK   901303     130     133 $E $fy 1107400000.0000 320.5000 17.9058 7.1244 78.3000 4572.0000 2286.0000 4572.0000 3152886.0000 0 $Composite 0 1; Spring_IMK   901403     140     143 $E $fy 1107400000.0000 320.5000 17.9058 7.1244 78.3000 4572.0000 2286.0000 4572.0000 3152886.0000 0 $Composite 0 1; 

# GRAVITY BEAMS SPRINGS
set gap 0.08;
Spring_Pinching   909304     930     934 1124553.3750 $gap 0; Spring_Pinching   909402     940     942 1124553.3750 $gap 0; 
Spring_Pinching   908304     830     834 1124553.3750 $gap 0; Spring_Pinching   908402     840     842 1124553.3750 $gap 0; 
Spring_Pinching   907304     730     734 1124553.3750 $gap 0; Spring_Pinching   907402     740     742 1124553.3750 $gap 0; 
Spring_Pinching   906304     630     634 1124553.3750 $gap 0; Spring_Pinching   906402     640     642 1124553.3750 $gap 0; 
Spring_Pinching   905304     530     534 1124553.3750 $gap 0; Spring_Pinching   905402     540     542 1124553.3750 $gap 0; 
Spring_Pinching   904304     430     434 1124553.3750 $gap 0; Spring_Pinching   904402     440     442 1124553.3750 $gap 0; 
Spring_Pinching   903304     330     334 1124553.3750 $gap 0; Spring_Pinching   903402     340     342 1124553.3750 $gap 0; 
Spring_Pinching   902304     230     234 1124553.3750 $gap 0; Spring_Pinching   902402     240     242 1124553.3750 $gap 0; 

###################################################################################################
#                                       BOUNDARY CONDITIONS                                       #
###################################################################################################

# MF SUPPORTS
fix 110 1 1 1; 
fix 120 1 1 1; 

# EGF SUPPORTS
fix 130 1 1 0; fix 140 1 1 0; 

# MF FLOOR MOVEMENT
equalDOF 409104 409204 1; 
equalDOF 408104 408204 1; 
equalDOF 407104 407204 1; 
equalDOF 406104 406204 1; 
equalDOF 405104 405204 1; 
equalDOF 404104 404204 1; 
equalDOF 403104 403204 1; 
equalDOF 402104 402204 1; 

# BEAM MID-SPAN HORIZONTAL MOVEMENT CONSTRAINT
equalDOF 408104 208101 1; 
equalDOF 406104 206101 1; 
equalDOF 404104 204101 1; 
equalDOF 402104 202101 1; 

# EGF FLOOR MOVEMENT
equalDOF 930 940 1;
equalDOF 830 840 1;
equalDOF 730 740 1;
equalDOF 630 640 1;
equalDOF 530 540 1;
equalDOF 430 440 1;
equalDOF 330 340 1;
equalDOF 230 240 1;


# BEAM MID-SPAN SAGGING CONSTRAINT
equalDOF 408104 208101 2; 
equalDOF 406104 206101 2; 
equalDOF 404104 204101 2; 
equalDOF 402104 202101 2; 

##################################################################################################
##################################################################################################
                                       puts "Model Built"
##################################################################################################
##################################################################################################

###################################################################################################
#                                             RECORDERS                                           #
###################################################################################################

# EIGEN VECTORS
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode1.out -node 402104 403104 404104 405104 406104 407104 408104 409104  -dof 1 "eigen  1";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode2.out -node 402104 403104 404104 405104 406104 407104 408104 409104  -dof 1 "eigen  2";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode3.out -node 402104 403104 404104 405104 406104 407104 408104 409104  -dof 1 "eigen  3";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode4.out -node 402104 403104 404104 405104 406104 407104 408104 409104  -dof 1 "eigen  4";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode5.out -node 402104 403104 404104 405104 406104 407104 408104 409104  -dof 1 "eigen  5";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode6.out -node 402104 403104 404104 405104 406104 407104 408104 409104  -dof 1 "eigen  6";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode7.out -node 402104 403104 404104 405104 406104 407104 408104 409104  -dof 1 "eigen  7";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode8.out -node 402104 403104 404104 405104 406104 407104 408104 409104  -dof 1 "eigen  8";

# TIME
recorder Node -file $MainFolder/$SubFolder/Time.out  -time -node 110 -dof 1 disp;

# SUPPORT REACTIONS
recorder Node -file $MainFolder/$SubFolder/Support1.out -node     110 -dof 1 2 6 reaction; recorder Node -file $MainFolder/$SubFolder/Support2.out -node     120 -dof 1 2 6 reaction; recorder Node -file $MainFolder/$SubFolder/Support3.out -node     130 -dof 1 2 6 reaction; recorder Node -file $MainFolder/$SubFolder/Support4.out -node     140 -dof 1 2 6 reaction; 

# STORY DRIFT RATIO
recorder Drift -file $MainFolder/$SubFolder/SDR8_MF.out -iNode  408104 -jNode  409104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR7_MF.out -iNode  407104 -jNode  408104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR6_MF.out -iNode  406104 -jNode  407104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR5_MF.out -iNode  405104 -jNode  406104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR4_MF.out -iNode  404104 -jNode  405104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR3_MF.out -iNode  403104 -jNode  404104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR2_MF.out -iNode  402104 -jNode  403104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR1_MF.out -iNode     110 -jNode  402104 -dof 1 -perpDirn 2; 

# COLUMN ELASTIC ELEMENT FORCES
recorder Element -file $MainFolder/$SubFolder/Column81.out -ele  608100 force; recorder Element -file $MainFolder/$SubFolder/Column82.out -ele  608200 force; recorder Element -file $MainFolder/$SubFolder/Column83.out -ele  608300 force; recorder Element -file $MainFolder/$SubFolder/Column84.out -ele  608400 force; 
recorder Element -file $MainFolder/$SubFolder/Column71.out -ele  607101 force; recorder Element -file $MainFolder/$SubFolder/Column72.out -ele  607201 force; recorder Element -file $MainFolder/$SubFolder/Column73.out -ele  607301 force; recorder Element -file $MainFolder/$SubFolder/Column74.out -ele  607401 force; 
recorder Element -file $MainFolder/$SubFolder/Column61.out -ele  606100 force; recorder Element -file $MainFolder/$SubFolder/Column62.out -ele  606200 force; recorder Element -file $MainFolder/$SubFolder/Column63.out -ele  606300 force; recorder Element -file $MainFolder/$SubFolder/Column64.out -ele  606400 force; 
recorder Element -file $MainFolder/$SubFolder/Column51.out -ele  605101 force; recorder Element -file $MainFolder/$SubFolder/Column52.out -ele  605201 force; recorder Element -file $MainFolder/$SubFolder/Column53.out -ele  605301 force; recorder Element -file $MainFolder/$SubFolder/Column54.out -ele  605401 force; 
recorder Element -file $MainFolder/$SubFolder/Column41.out -ele  604100 force; recorder Element -file $MainFolder/$SubFolder/Column42.out -ele  604200 force; recorder Element -file $MainFolder/$SubFolder/Column43.out -ele  604300 force; recorder Element -file $MainFolder/$SubFolder/Column44.out -ele  604400 force; 
recorder Element -file $MainFolder/$SubFolder/Column31.out -ele  603101 force; recorder Element -file $MainFolder/$SubFolder/Column32.out -ele  603201 force; recorder Element -file $MainFolder/$SubFolder/Column33.out -ele  603301 force; recorder Element -file $MainFolder/$SubFolder/Column34.out -ele  603401 force; 
recorder Element -file $MainFolder/$SubFolder/Column21.out -ele  602100 force; recorder Element -file $MainFolder/$SubFolder/Column22.out -ele  602200 force; recorder Element -file $MainFolder/$SubFolder/Column23.out -ele  602300 force; recorder Element -file $MainFolder/$SubFolder/Column24.out -ele  602400 force; 
recorder Element -file $MainFolder/$SubFolder/Column11.out -ele  601100 force; recorder Element -file $MainFolder/$SubFolder/Column12.out -ele  601200 force; recorder Element -file $MainFolder/$SubFolder/Column13.out -ele  601300 force; recorder Element -file $MainFolder/$SubFolder/Column14.out -ele  601400 force; 

# BRACE CORNER RIGID LINKS FORCES
recorder Element -file $MainFolder/$SubFolder/CGP81.out -ele  709199 globalForce; recorder Element -file $MainFolder/$SubFolder/CGP82.out -ele  709299 globalForce; 
recorder Element -file $MainFolder/$SubFolder/CGP71.out -ele  707111 globalForce; recorder Element -file $MainFolder/$SubFolder/CGP72.out -ele  707211 globalForce; 
recorder Element -file $MainFolder/$SubFolder/CGP61.out -ele  707199 globalForce; recorder Element -file $MainFolder/$SubFolder/CGP62.out -ele  707299 globalForce; 
recorder Element -file $MainFolder/$SubFolder/CGP51.out -ele  705111 globalForce; recorder Element -file $MainFolder/$SubFolder/CGP52.out -ele  705211 globalForce; 
recorder Element -file $MainFolder/$SubFolder/CGP41.out -ele  705199 globalForce; recorder Element -file $MainFolder/$SubFolder/CGP42.out -ele  705299 globalForce; 
recorder Element -file $MainFolder/$SubFolder/CGP31.out -ele  703111 globalForce; recorder Element -file $MainFolder/$SubFolder/CGP32.out -ele  703211 globalForce; 
recorder Element -file $MainFolder/$SubFolder/CGP21.out -ele  703199 globalForce; recorder Element -file $MainFolder/$SubFolder/CGP22.out -ele  703299 globalForce; 
recorder Element -file $MainFolder/$SubFolder/CGP11.out -ele  701111 globalForce; recorder Element -file $MainFolder/$SubFolder/CGP12.out -ele  701211 globalForce; 

###################################################################################################
#                                              NODAL MASS                                         #
###################################################################################################

set g 9810.00;
mass 409104 0.0132  1.e-9 1.e-9; mass 409204 0.0132  1.e-9 1.e-9; mass 930 0.0793  1.e-9 1.e-9; mass 940 0.0793  1.e-9 1.e-9; 
mass 408104 0.0152  1.e-9 1.e-9; mass 408204 0.0152  1.e-9 1.e-9; mass 830 0.0851  1.e-9 1.e-9; mass 840 0.0851  1.e-9 1.e-9; 
mass 407104 0.0152  1.e-9 1.e-9; mass 407204 0.0152  1.e-9 1.e-9; mass 730 0.0851  1.e-9 1.e-9; mass 740 0.0851  1.e-9 1.e-9; 
mass 406104 0.0152  1.e-9 1.e-9; mass 406204 0.0152  1.e-9 1.e-9; mass 630 0.0851  1.e-9 1.e-9; mass 640 0.0851  1.e-9 1.e-9; 
mass 405104 0.0152  1.e-9 1.e-9; mass 405204 0.0152  1.e-9 1.e-9; mass 530 0.0851  1.e-9 1.e-9; mass 540 0.0851  1.e-9 1.e-9; 
mass 404104 0.0152  1.e-9 1.e-9; mass 404204 0.0152  1.e-9 1.e-9; mass 430 0.0851  1.e-9 1.e-9; mass 440 0.0851  1.e-9 1.e-9; 
mass 403104 0.0152  1.e-9 1.e-9; mass 403204 0.0152  1.e-9 1.e-9; mass 330 0.0851  1.e-9 1.e-9; mass 340 0.0851  1.e-9 1.e-9; 
mass 402104 0.0158  1.e-9 1.e-9; mass 402204 0.0158  1.e-9 1.e-9; mass 230 0.0869  1.e-9 1.e-9; mass 240 0.0869  1.e-9 1.e-9; 

constraints Plain;

###################################################################################################
#                                        EIGEN VALUE ANALYSIS                                     #
###################################################################################################

set pi [expr 2.0*asin(1.0)];
set nEigen 8;
set lambdaN [eigen [expr $nEigen]];
set lambda1 [lindex $lambdaN 0];
set lambda2 [lindex $lambdaN 1];
set lambda3 [lindex $lambdaN 2];
set lambda4 [lindex $lambdaN 3];
set lambda5 [lindex $lambdaN 4];
set lambda6 [lindex $lambdaN 5];
set lambda7 [lindex $lambdaN 6];
set lambda8 [lindex $lambdaN 7];
set w1 [expr pow($lambda1,0.5)];
set w2 [expr pow($lambda2,0.5)];
set w3 [expr pow($lambda3,0.5)];
set w4 [expr pow($lambda4,0.5)];
set w5 [expr pow($lambda5,0.5)];
set w6 [expr pow($lambda6,0.5)];
set w7 [expr pow($lambda7,0.5)];
set w8 [expr pow($lambda8,0.5)];
set T1 [expr round(2.0*$pi/$w1 *1000.)/1000.];
set T2 [expr round(2.0*$pi/$w2 *1000.)/1000.];
set T3 [expr round(2.0*$pi/$w3 *1000.)/1000.];
set T4 [expr round(2.0*$pi/$w4 *1000.)/1000.];
set T5 [expr round(2.0*$pi/$w5 *1000.)/1000.];
set T6 [expr round(2.0*$pi/$w6 *1000.)/1000.];
set T7 [expr round(2.0*$pi/$w7 *1000.)/1000.];
set T8 [expr round(2.0*$pi/$w8 *1000.)/1000.];
puts "T1 = $T1 s";
puts "T2 = $T2 s";
puts "T3 = $T3 s";
cd $RFpath;
cd "Results"
cd "EigenAnalysis"
set fileX [open "EigenPeriod.out" w];
puts $fileX $T1;puts $fileX $T2;puts $fileX $T3;puts $fileX $T4;puts $fileX $T5;puts $fileX $T6;puts $fileX $T7;puts $fileX $T8;close $fileX;
cd $MainDir;

constraints Plain;
algorithm Newton;
integrator LoadControl 1;
analysis Static;
analyze 1;

###################################################################################################
###################################################################################################
									puts "Eigen Analysis Done"
###################################################################################################
###################################################################################################

###################################################################################################
#                                   DYNAMIC EARTHQUAKE ANALYSIS                                   #
###################################################################################################

if {$EQ==1} {

# Rayleigh Damping
global Sigma_zeta; global xRandom;
set zeta 0.020;
set SigmaX $Sigma_zeta; Generate_lognrmrand $zeta 		$SigmaX; 		set zeta 	$xRandom;
set a0 [expr $zeta*2.0*$w1*$w3/($w1 + $w3)];
set a1 [expr $zeta*2.0/($w1 + $w3)];
set a1_mod [expr $a1*(1.0+$n)/$n];
region 1 -ele  608100 608200 607102 607202 607101 607201 606100 606200 605102 605202 605101 605201 604100 604200 603102 603202 603101 603201 602100 602200 601100 601200 509100 508101 508102 507100 506101 506102 505100 504101 504102 503100 502101 502102  -rayleigh 0.0 0.0 $a1_mod 0.0;
region 2 -node  402104 402204 230 240 403104 403204 330 340 404104 404204 430 440 405104 405204 530 540 406104 406204 630 640 407104 407204 730 740 408104 408204 830 840 409104 409204 930 940  -rayleigh $a0 0.0 0.0 0.0;
region 3 -eleRange  900000  999999 -rayleigh 0.0 0.0 [expr $a1_mod/10] 0.0;

# GROUND MOTION ACCELERATION FILE INPUT
set AccelSeries "Series -dt $GMdt -filePath GM.txt -factor  [expr $EqSF * $g]"
pattern UniformExcitation  200 1 -accel $AccelSeries

set MF_FloorNodes [list  402104 403104 404104 405104 406104 407104 408104 409104 ];
set EGF_FloorNodes [list  230 330 430 530 630 730 830 930 ];
set GMduration [expr $GMdt*$GMpoints];
set FVduration 10.000000;
set NumSteps [expr round(($GMduration + $FVduration)/$GMdt)];	# number of steps in analysis
set totTime [expr $GMdt*$NumSteps];                            # Total time of analysis
set dtAnalysis [expr 0.500000*$GMdt];                             	# dt of Analysis

DynamicAnalysisCollapseSolverX  $GMdt	$dtAnalysis	$totTime $NStory	 0.15   $MF_FloorNodes	$EGF_FloorNodes	4572.00 3960.00 1 $StartTime $MaxRunTime;

###################################################################################################
###################################################################################################
							puts "Ground Motion Done. End Time: [getTime]"
###################################################################################################
###################################################################################################
}

wipe all;
