####################################################################################################
####################################################################################################
#                                        4-story MRF Building
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
set  EQ 1;  # Regular expression anchor
set  PO 0;  # Regular expression anchor
set  ELF 0;
set  Composite 0;
set  ShowAnimation 1;
# set  MainDir {D:\FM_2D\application};
# set  RFpath {F:\MRF\FM2Dmodels};
# set  MainFolder {F:\MRF\FM2Dmodels\Results};
set  ModePO 1;
set  DriftPO 0.100000;
set  DampModeI 1;
set  DampModeJ 3;
set  zeta 0.020000;

########################################################################
#Code Below is Only Needed To Run Dynamic Analysis through MATLAB Code #
########################################################################

# Opens file to read (r) the scale factor
# set fileID1 [open SF.txt r];
# set EqSF [read $fileID1];

set MainFolder "H:/MRF_results/test/4SMRF";
set GMname "th5";
set SubFolder "th5";
set GMdt 0.01;
set GMpoints 5590;
set GMduration 55.89;
set FVduration 30;
set EqSF 2.8402883985143106;
set GMFile "GMs/$GMname.th";

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
source ConstructPanel_Rectangle.tcl;
source DynamicAnalysisCollapseSolverX.tcl;
source Generate_lognrmrand.tcl;
source add/add_VSL.tcl

####################################################################################################
#                                          Create Results Folders                                  #
####################################################################################################

# RESULT FOLDER
# set SubFolder  $GMname;
# cd $RFpath;
# file mkdir "Results";
# cd "Results"
# file mkdir $SubFolder;
# cd $MainDir;
file mkdir $MainFolder;
file mkdir $MainFolder/EigenAnalysis;
file mkdir $MainFolder/$SubFolder;
puts "File: $SubFolder"

####################################################################################################
#                                              INPUT                                               #
####################################################################################################

# FRAME CENTERLINE DIMENSIONS
set NStory  4;
set NBay    3;

# MATERIAL PROPERTIES
set E   200.000;
set mu  0.300; 
set fy  [expr 0.345 *   1.0];

# BASIC MATERIALS
uniaxialMaterial Elastic  9  1.e-9; 		#Flexible Material 
uniaxialMaterial Elastic  99 1000000000.;  #Rigid Material 
# uniaxialMaterial UVCuniaxial  666 195.9054 0.3247 0.1386 12.7000 0.0000 1.0000 2 23.5580 286.2000 1.9609 15.6000; #Voce-Chaboche Material;
uniaxialMaterial Steel01 666 $fy $E 0.005
uniaxialMaterial Elastic 667 $E

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
set Comp_I    1.000;
set Comp_I_GC 1.000;

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
set Sigma_zeta   1.e-9;
global Sigma_fy Sigma_fyB Sigma_fyG Sigma_GI; global xRandom;
set SigmaX $Sigma_fy;  Generate_lognrmrand $fy 	$SigmaX; 	set fy      $xRandom;

####################################################################################################
#                                          PRE-CALCULATIONS                                        #
####################################################################################################

# REDUCED BEAM SECTION CONNECTION DISTANCE FROM COLUMN
set L_RBS5  [expr  0.100 * 192.02 +  0.000 * 462.28/2.];
set L_RBS4  [expr  0.100 * 192.02 +  0.000 * 462.28/2.];
set L_RBS3  [expr  0.100 * 228.35 +  0.000 * 607.06/2.];
set L_RBS2  [expr  0.100 * 228.35 +  0.000 * 607.06/2.];

# FRAME GRID LINES
set Floor5  16300.00;
set Floor4  12300.00;
set Floor3  8300.00;
set Floor2  4300.00;
set Floor1 0.0;

set Axis1 0.0;
set Axis2 6100.00;
set Axis3 12200.00;
set Axis4 18300.00;
set Axis5 24400.00;
set Axis6 30500.00;

set HBuilding 16300.00;
set WFrame 18300.00;
variable HBuilding 16300.00;

####################################################################################################
#                                                  NODES                                           #
####################################################################################################

# COMMAND SYNTAX 
# node $NodeID  $X-Coordinate  $Y-Coordinate;

#SUPPORT NODES
node 110   $Axis1  $Floor1; node 120   $Axis2  $Floor1; node 130   $Axis3  $Floor1; node 140   $Axis4  $Floor1; node 150   $Axis5  $Floor1;# node 160   $Axis6  $Floor1; 

# EGF COLUMN GRID NODES
node 550   $Axis5  $Floor5;# node 560   $Axis6  $Floor5; 
node 450   $Axis5  $Floor4;# node 460   $Axis6  $Floor4; 
node 350   $Axis5  $Floor3;# node 360   $Axis6  $Floor3; 
node 250   $Axis5  $Floor2;# node 260   $Axis6  $Floor2; 

# EGF COLUMN NODES
node 551  $Axis5  $Floor5;# node 561  $Axis6  $Floor5; 
node 453  $Axis5  $Floor4;# node 463  $Axis6  $Floor4; 
node 451  $Axis5  $Floor4;# node 461  $Axis6  $Floor4; 
node 353  $Axis5  $Floor3;# node 363  $Axis6  $Floor3; 
node 351  $Axis5  $Floor3;# node 361  $Axis6  $Floor3; 
node 253  $Axis5  $Floor2;# node 263  $Axis6  $Floor2; 
node 251  $Axis5  $Floor2;# node 261  $Axis6  $Floor2; 
node 153  $Axis5  $Floor1;# node 163  $Axis6  $Floor1; 

# EGF BEAM NODES
# node 554  $Axis5  $Floor5; node 562  $Axis6  $Floor5; 
# node 454  $Axis5  $Floor4; node 462  $Axis6  $Floor4; 
# node 354  $Axis5  $Floor3; node 362  $Axis6  $Floor3; 
# node 254  $Axis5  $Floor2; node 262  $Axis6  $Floor2; 

# MF COLUMN NODES
node 511  $Axis1 [expr $Floor5 - 462.28/2]; node 521  $Axis2 [expr $Floor5 - 462.28/2]; node 531  $Axis3 [expr $Floor5 - 462.28/2]; node 541  $Axis4 [expr $Floor5 - 462.28/2]; 
node 413  $Axis1 [expr $Floor4 + 462.28/2]; node 423  $Axis2 [expr $Floor4 + 462.28/2]; node 433  $Axis3 [expr $Floor4 + 462.28/2]; node 443  $Axis4 [expr $Floor4 + 462.28/2]; 
node 411  $Axis1 [expr $Floor4 - 462.28/2]; node 421  $Axis2 [expr $Floor4 - 462.28/2]; node 431  $Axis3 [expr $Floor4 - 462.28/2]; node 441  $Axis4 [expr $Floor4 - 462.28/2]; 
node 313  $Axis1 [expr $Floor3 + 607.06/2]; node 323  $Axis2 [expr $Floor3 + 607.06/2]; node 333  $Axis3 [expr $Floor3 + 607.06/2]; node 343  $Axis4 [expr $Floor3 + 607.06/2]; 
node 311  $Axis1 [expr $Floor3 - 607.06/2]; node 321  $Axis2 [expr $Floor3 - 607.06/2]; node 331  $Axis3 [expr $Floor3 - 607.06/2]; node 341  $Axis4 [expr $Floor3 - 607.06/2]; 
node 213  $Axis1 [expr $Floor2 + 607.06/2]; node 223  $Axis2 [expr $Floor2 + 607.06/2]; node 233  $Axis3 [expr $Floor2 + 607.06/2]; node 243  $Axis4 [expr $Floor2 + 607.06/2]; 
node 211  $Axis1 [expr $Floor2 - 607.06/2]; node 221  $Axis2 [expr $Floor2 - 607.06/2]; node 231  $Axis3 [expr $Floor2 - 607.06/2]; node 241  $Axis4 [expr $Floor2 - 607.06/2]; 
node 113  $Axis1 $Floor1; node 123  $Axis2 $Floor1; node 133  $Axis3 $Floor1; node 143  $Axis4 $Floor1; 

# MF BEAM NODES
node 514   [expr $Axis1 + $L_RBS5 + 607.06/2] $Floor5; node 522   [expr $Axis2 - $L_RBS5 - 612.14/2] $Floor5; node 524   [expr $Axis2 + $L_RBS5 + 612.14/2] $Floor5; node 532   [expr $Axis3 - $L_RBS5 - 612.14/2] $Floor5; node 534   [expr $Axis3 + $L_RBS5 + 612.14/2] $Floor5; node 542   [expr $Axis4 - $L_RBS5 - 607.06/2] $Floor5; 
node 414   [expr $Axis1 + $L_RBS4 + 622.30/2] $Floor4; node 422   [expr $Axis2 - $L_RBS4 - 627.38/2] $Floor4; node 424   [expr $Axis2 + $L_RBS4 + 627.38/2] $Floor4; node 432   [expr $Axis3 - $L_RBS4 - 627.38/2] $Floor4; node 434   [expr $Axis3 + $L_RBS4 + 627.38/2] $Floor4; node 442   [expr $Axis4 - $L_RBS4 - 622.30/2] $Floor4; 
node 314   [expr $Axis1 + $L_RBS3 + 622.30/2] $Floor3; node 322   [expr $Axis2 - $L_RBS3 - 627.38/2] $Floor3; node 324   [expr $Axis2 + $L_RBS3 + 627.38/2] $Floor3; node 332   [expr $Axis3 - $L_RBS3 - 627.38/2] $Floor3; node 334   [expr $Axis3 + $L_RBS3 + 627.38/2] $Floor3; node 342   [expr $Axis4 - $L_RBS3 - 622.30/2] $Floor3; 
node 214   [expr $Axis1 + $L_RBS2 + 622.30/2] $Floor2; node 222   [expr $Axis2 - $L_RBS2 - 627.38/2] $Floor2; node 224   [expr $Axis2 + $L_RBS2 + 627.38/2] $Floor2; node 232   [expr $Axis3 - $L_RBS2 - 627.38/2] $Floor2; node 234   [expr $Axis3 + $L_RBS2 + 627.38/2] $Floor2; node 242   [expr $Axis4 - $L_RBS2 - 622.30/2] $Floor2; 

# BEAM SPRING NODES
node 5140   [expr $Axis1 + $L_RBS5 + 607.06/2] $Floor5; node 5220   [expr $Axis2 - $L_RBS5 - 612.14/2] $Floor5; node 5240   [expr $Axis2 + $L_RBS5 + 612.14/2] $Floor5; node 5320   [expr $Axis3 - $L_RBS5 - 612.14/2] $Floor5; node 5340   [expr $Axis3 + $L_RBS5 + 612.14/2] $Floor5; node 5420   [expr $Axis4 - $L_RBS5 - 607.06/2] $Floor5; 
node 4140   [expr $Axis1 + $L_RBS4 + 622.30/2] $Floor4; node 4220   [expr $Axis2 - $L_RBS4 - 627.38/2] $Floor4; node 4240   [expr $Axis2 + $L_RBS4 + 627.38/2] $Floor4; node 4320   [expr $Axis3 - $L_RBS4 - 627.38/2] $Floor4; node 4340   [expr $Axis3 + $L_RBS4 + 627.38/2] $Floor4; node 4420   [expr $Axis4 - $L_RBS4 - 622.30/2] $Floor4; 
node 3140   [expr $Axis1 + $L_RBS3 + 622.30/2] $Floor3; node 3220   [expr $Axis2 - $L_RBS3 - 627.38/2] $Floor3; node 3240   [expr $Axis2 + $L_RBS3 + 627.38/2] $Floor3; node 3320   [expr $Axis3 - $L_RBS3 - 627.38/2] $Floor3; node 3340   [expr $Axis3 + $L_RBS3 + 627.38/2] $Floor3; node 3420   [expr $Axis4 - $L_RBS3 - 622.30/2] $Floor3; 
node 2140   [expr $Axis1 + $L_RBS2 + 622.30/2] $Floor2; node 2220   [expr $Axis2 - $L_RBS2 - 627.38/2] $Floor2; node 2240   [expr $Axis2 + $L_RBS2 + 627.38/2] $Floor2; node 2320   [expr $Axis3 - $L_RBS2 - 627.38/2] $Floor2; node 2340   [expr $Axis3 + $L_RBS2 + 627.38/2] $Floor2; node 2420   [expr $Axis4 - $L_RBS2 - 622.30/2] $Floor2; 

# COLUMN SPLICE NODES
node 103172 $Axis1 [expr ($Floor3 + 0.50 * 4000)]; node 103272 $Axis2 [expr ($Floor3 + 0.50 * 4000)]; node 103372 $Axis3 [expr ($Floor3 + 0.50 * 4000)]; node 103472 $Axis4 [expr ($Floor3 + 0.50 * 4000)]; node 103572 $Axis5 [expr ($Floor3 + 0.50 * 4000)];# node 103672 $Axis6 [expr ($Floor3 + 0.50 * 4000)]; 
node 103171 $Axis1 [expr ($Floor3 + 0.50 * 4000)]; node 103271 $Axis2 [expr ($Floor3 + 0.50 * 4000)]; node 103371 $Axis3 [expr ($Floor3 + 0.50 * 4000)]; node 103471 $Axis4 [expr ($Floor3 + 0.50 * 4000)]; node 103571 $Axis5 [expr ($Floor3 + 0.50 * 4000)];# node 103671 $Axis6 [expr ($Floor3 + 0.50 * 4000)]; 

###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

# PANEL ZONE NODES AND ELASTIC ELEMENTS
# Command Syntax; 
# ConstructPanel_Rectangle Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag 
ConstructPanel_Rectangle 1 5 $Axis1 $Floor5 $E $A_Stiff $I_Stiff 607.06 462.28 $trans_selected; ConstructPanel_Rectangle 2 5 $Axis2 $Floor5 $E $A_Stiff $I_Stiff 612.14 462.28 $trans_selected; ConstructPanel_Rectangle 3 5 $Axis3 $Floor5 $E $A_Stiff $I_Stiff 612.14 462.28 $trans_selected; ConstructPanel_Rectangle 4 5 $Axis4 $Floor5 $E $A_Stiff $I_Stiff 607.06 462.28 $trans_selected; 
ConstructPanel_Rectangle 1 4 $Axis1 $Floor4 $E $A_Stiff $I_Stiff 622.30 462.28 $trans_selected; ConstructPanel_Rectangle 2 4 $Axis2 $Floor4 $E $A_Stiff $I_Stiff 627.38 462.28 $trans_selected; ConstructPanel_Rectangle 3 4 $Axis3 $Floor4 $E $A_Stiff $I_Stiff 627.38 462.28 $trans_selected; ConstructPanel_Rectangle 4 4 $Axis4 $Floor4 $E $A_Stiff $I_Stiff 622.30 462.28 $trans_selected; 
ConstructPanel_Rectangle 1 3 $Axis1 $Floor3 $E $A_Stiff $I_Stiff 622.30 607.06 $trans_selected; ConstructPanel_Rectangle 2 3 $Axis2 $Floor3 $E $A_Stiff $I_Stiff 627.38 607.06 $trans_selected; ConstructPanel_Rectangle 3 3 $Axis3 $Floor3 $E $A_Stiff $I_Stiff 627.38 607.06 $trans_selected; ConstructPanel_Rectangle 4 3 $Axis4 $Floor3 $E $A_Stiff $I_Stiff 622.30 607.06 $trans_selected; 
ConstructPanel_Rectangle 1 2 $Axis1 $Floor2 $E $A_Stiff $I_Stiff 622.30 607.06 $trans_selected; ConstructPanel_Rectangle 2 2 $Axis2 $Floor2 $E $A_Stiff $I_Stiff 627.38 607.06 $trans_selected; ConstructPanel_Rectangle 3 2 $Axis3 $Floor2 $E $A_Stiff $I_Stiff 627.38 607.06 $trans_selected; ConstructPanel_Rectangle 4 2 $Axis4 $Floor2 $E $A_Stiff $I_Stiff 622.30 607.06 $trans_selected; 

####################################################################################################
#                                          PANEL ZONE SPRINGS                                      #
####################################################################################################

# COMMAND SYNTAX 
# Spring_PZ    Element_ID Node_i Node_j E mu fy tw_Col tdp d_Col d_Beam tf_Col bf_Col Ic trib ts Response_ID transfTag
Spring_PZ    905100 405109 405110 $E $mu [expr $fy *   1.0] 11.18   6.35 607.06 462.28 17.27 228.35 874085993.76 90.000 100.000 2 1; Spring_PZ    905200 405209 405210 $E $mu [expr $fy *   1.0] 11.94  22.22 612.14 462.28 19.56 229.11 986468478.67 90.000 100.000 0 1; Spring_PZ    905300 405309 405310 $E $mu [expr $fy *   1.0] 11.94  22.22 612.14 462.28 19.56 229.11 986468478.67 90.000 100.000 0 1; Spring_PZ    905400 405409 405410 $E $mu [expr $fy *   1.0] 11.18   6.35 607.06 462.28 17.27 228.35 874085993.76 90.000 100.000 2 1; 
Spring_PZ    904100 404109 404110 $E $mu [expr $fy *   1.0] 11.18   6.35 607.06 462.28 17.27 228.35 874085993.76 90.000 100.000 2 1; Spring_PZ    904200 404209 404210 $E $mu [expr $fy *   1.0] 11.94  22.22 612.14 462.28 19.56 229.11 986468478.67 90.000 100.000 0 1; Spring_PZ    904300 404309 404310 $E $mu [expr $fy *   1.0] 11.94  22.22 612.14 462.28 19.56 229.11 986468478.67 90.000 100.000 0 1; Spring_PZ    904400 404409 404410 $E $mu [expr $fy *   1.0] 11.18   6.35 607.06 462.28 17.27 228.35 874085993.76 90.000 100.000 2 1; 
Spring_PZ    903100 403109 403110 $E $mu [expr $fy *   1.0] 13.97   6.35 622.30 607.06 24.89 228.60 1248694276.80 90.000 100.000 2 1; Spring_PZ    903200 403209 403210 $E $mu [expr $fy *   1.0] 16.51  23.81 627.38 607.06 27.69 327.66 1906339929.25 90.000 100.000 0 1; Spring_PZ    903300 403309 403310 $E $mu [expr $fy *   1.0] 16.51  23.81 627.38 607.06 27.69 327.66 1906339929.25 90.000 100.000 0 1; Spring_PZ    903400 403409 403410 $E $mu [expr $fy *   1.0] 13.97   6.35 622.30 607.06 24.89 228.60 1248694276.80 90.000 100.000 2 1; 
Spring_PZ    902100 402109 402110 $E $mu [expr $fy *   1.0] 13.97   6.35 622.30 607.06 24.89 228.60 1248694276.80 90.000 100.000 2 1; Spring_PZ    902200 402209 402210 $E $mu [expr $fy *   1.0] 16.51  23.81 627.38 607.06 27.69 327.66 1906339929.25 90.000 100.000 0 1; Spring_PZ    902300 402309 402310 $E $mu [expr $fy *   1.0] 16.51  23.81 627.38 607.06 27.69 327.66 1906339929.25 90.000 100.000 0 1; Spring_PZ    902400 402409 402410 $E $mu [expr $fy *   1.0] 13.97   6.35 622.30 607.06 24.89 228.60 1248694276.80 90.000 100.000 2 1; 

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
# element ModElasticBeam2d   604100      413      511  14451.5840 $E [expr ($n+1)/$n*874085993.7600]  $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   604200      423      521  15935.4520 $E [expr ($n+1)/$n*986468478.6720]  $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   604300      433      531  15935.4520 $E [expr ($n+1)/$n*986468478.6720] $K11_2 $K33_2 $K44_2 $trans_selected;  element ModElasticBeam2d   604400      443      541  14451.5840 $E [expr ($n+1)/$n*874085993.7600]  $K11_2 $K33_2 $K44_2 $trans_selected; 
# element ModElasticBeam2d   603102   103172      411 14451.5840  $E [expr ($n+1)/$n*874085993.7600]  $K33_1 $K11_1 $K44_1 $trans_selected; element ModElasticBeam2d   603202   103272      421 15935.4520  $E [expr ($n+1)/$n*986468478.6720]  $K33_1 $K11_1 $K44_1 $trans_selected; element ModElasticBeam2d   603302   103372      431 15935.4520  $E [expr ($n+1)/$n*986468478.6720] $K33_1 $K11_1 $K44_1 $trans_selected;  element ModElasticBeam2d   603402   103472      441 14451.5840  $E [expr ($n+1)/$n*874085993.7600]  $K33_1 $K11_1 $K44_1 $trans_selected;  
# element ModElasticBeam2d   603101      313   103171 19548.3480  $E [expr ($n+1)/$n*1248694276.8000] $K33_1 $K11_1 $K44_1 $trans_selected; element ModElasticBeam2d   603201      323   103271 27741.8800  $E [expr ($n+1)/$n*1906339929.2480] $K33_1 $K11_1 $K44_1 $trans_selected; element ModElasticBeam2d   603301      333   103371 27741.8800  $E [expr ($n+1)/$n*1906339929.2480] $K33_1 $K11_1 $K44_1 $trans_selected; element ModElasticBeam2d   603401      343   103471 19548.3480  $E [expr ($n+1)/$n*1248694276.8000] $K33_1 $K11_1 $K44_1 $trans_selected;  
# element ModElasticBeam2d   602100      213      311  19548.3480 $E [expr ($n+1)/$n*1248694276.8000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   602200      223      321  27741.8800 $E [expr ($n+1)/$n*1906339929.2480] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   602300      233      331  27741.8800 $E [expr ($n+1)/$n*1906339929.2480] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   602400      243      341  19548.3480 $E [expr ($n+1)/$n*1248694276.8000] $K11_2 $K33_2 $K44_2 $trans_selected; 
# element ModElasticBeam2d   601100      113      211  19548.3480 $E [expr ($n+1)/$n*1248694276.8000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   601200      123      221  27741.8800 $E [expr ($n+1)/$n*1906339929.2480] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   601300      133      231  27741.8800 $E [expr ($n+1)/$n*1906339929.2480] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   601400      143      241  19548.3480 $E [expr ($n+1)/$n*1248694276.8000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   604100      413      511  14451.5840 $E [expr ($n+1)/$n*874085993.7600]  $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   604200      423      521  15935.4520 $E [expr ($n+1)/$n*986468478.6720]  $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   604300      433      531  15935.4520 $E [expr ($n+1)/$n*986468478.6720]  $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   604400      443      541  14451.5840 $E [expr ($n+1)/$n*874085993.7600]  $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   603102   103172      411 14451.5840  $E [expr ($n+1)/$n*874085993.7600]  $K11_1 $K33_1 $K44_1 $trans_selected; element ModElasticBeam2d   603202   103272      421 15935.4520  $E [expr ($n+1)/$n*986468478.6720]  $K11_1 $K33_1 $K44_1 $trans_selected; element ModElasticBeam2d   603302   103372      431 15935.4520  $E [expr ($n+1)/$n*986468478.6720]  $K11_1 $K33_1 $K44_1 $trans_selected; element ModElasticBeam2d   603402   103472      441 14451.5840  $E [expr ($n+1)/$n*874085993.7600]  $K11_1 $K33_1 $K44_1 $trans_selected;  
element ModElasticBeam2d   603101      313   103171 19548.3480  $E [expr ($n+1)/$n*1248694276.8000] $K11_1 $K33_1 $K44_1 $trans_selected; element ModElasticBeam2d   603201      323   103271 27741.8800  $E [expr ($n+1)/$n*1906339929.2480] $K11_1 $K33_1 $K44_1 $trans_selected; element ModElasticBeam2d   603301      333   103371 27741.8800  $E [expr ($n+1)/$n*1906339929.2480] $K11_1 $K33_1 $K44_1 $trans_selected; element ModElasticBeam2d   603401      343   103471 19548.3480  $E [expr ($n+1)/$n*1248694276.8000] $K11_1 $K33_1 $K44_1 $trans_selected;  
element ModElasticBeam2d   602100      213      311  19548.3480 $E [expr ($n+1)/$n*1248694276.8000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   602200      223      321  27741.8800 $E [expr ($n+1)/$n*1906339929.2480] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   602300      233      331  27741.8800 $E [expr ($n+1)/$n*1906339929.2480] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   602400      243      341  19548.3480 $E [expr ($n+1)/$n*1248694276.8000] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   601100      113      211  19548.3480 $E [expr ($n+1)/$n*1248694276.8000] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   601200      123      221  27741.8800 $E [expr ($n+1)/$n*1906339929.2480] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   601300      133      231  27741.8800 $E [expr ($n+1)/$n*1906339929.2480] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   601400      143      241  19548.3480 $E [expr ($n+1)/$n*1248694276.8000] $K11_2 $K33_2 $K44_2 $trans_selected; 

# BEAMS
# Note: Each original beam element is divided into two beams, with tag number equal to the old tag plus 1 and 2, respectively.
# ↓ This node is the middle node of the two new beam elements.
node 52400 [expr ([nodeCoord 524 1] + [nodeCoord 532 1]) / 2.0] [nodeCoord 524 2] 0; element ModElasticBeam2d   5052001      524      52400  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   5052002      52400      532  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected;
node 42400 [expr ([nodeCoord 424 1] + [nodeCoord 432 1]) / 2.0] [nodeCoord 424 2] 0; element ModElasticBeam2d   5042001      424      42400  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   5042002      42400      432  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected;
node 32400 [expr ([nodeCoord 324 1] + [nodeCoord 332 1]) / 2.0] [nodeCoord 324 2] 0; element ModElasticBeam2d   5032001      324      32400  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   5032002      32400      332  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected;
node 22400 [expr ([nodeCoord 224 1] + [nodeCoord 232 1]) / 2.0] [nodeCoord 224 2] 0; element ModElasticBeam2d   5022001      224      22400  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected; element ModElasticBeam2d   5022002      22400      232  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected;

# delete the old beam element
element ModElasticBeam2d   505100      514      522  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected;        element ModElasticBeam2d   505300      534      542  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   504100      414      422  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected;        element ModElasticBeam2d   504300      434      442  11354.8160 $E [expr ($n+1)/$n*0.90*$Comp_I*409571722.7904] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   503100      314      322  14451.5840 $E [expr ($n+1)/$n*0.90*$Comp_I*874085993.7600] $K11_2 $K33_2 $K44_2 $trans_selected;        element ModElasticBeam2d   503300      334      342  14451.5840 $E [expr ($n+1)/$n*0.90*$Comp_I*874085993.7600] $K11_2 $K33_2 $K44_2 $trans_selected; 
element ModElasticBeam2d   502100      214      222  14451.5840 $E [expr ($n+1)/$n*0.90*$Comp_I*874085993.7600] $K11_2 $K33_2 $K44_2 $trans_selected;        element ModElasticBeam2d   502300      234      242  14451.5840 $E [expr ($n+1)/$n*0.90*$Comp_I*874085993.7600] $K11_2 $K33_2 $K44_2 $trans_selected; 

####################################################################################################
#                                      Vertical Shear Link                                         #
####################################################################################################
# add vertical shear link
#       NodeA NodeB  NodeC  h     A_brace  material   all parameters
add_VSL 52400 404209 404308 500.0   300     Steel02   300.0 300.0 0.005 18.5 0.925 0.15;
add_VSL 42400 403209 403308 500.0   300     Steel02   300.0 300.0 0.005 18.5 0.925 0.15;
add_VSL 32400 402209 402308 500.0   300     Steel02   300.0 300.0 0.005 18.5 0.925 0.15;
add_VSL 22400 120    130    500.0   300     Steel02   300.0 300.0 0.005 18.5 0.925 0.15;

recorder Element -file $MainFolder/$SubFolder/Link42.out -ele 52400 material 2 stressStrain;
recorder Element -file $MainFolder/$SubFolder/Link32.out -ele 42400 material 2 stressStrain;
recorder Element -file $MainFolder/$SubFolder/Link22.out -ele 32400 material 2 stressStrain;
recorder Element -file $MainFolder/$SubFolder/Link12.out -ele 22400 material 2 stressStrain;


####################################################################################################
#                                      ELASTIC RBS ELEMENTS                                        #
####################################################################################################

element elasticBeamColumn 505104 405104 5140 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 505202 405202 5220 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 505204 405204 5240 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 505302 405302 5320 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 505304 405304 5340 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 505402 405402 5420 11354.816 $E [expr $Comp_I*409571722.790] 1; 
element elasticBeamColumn 504104 404104 4140 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 504202 404202 4220 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 504204 404204 4240 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 504302 404302 4320 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 504304 404304 4340 11354.816 $E [expr $Comp_I*409571722.790] 1; element elasticBeamColumn 504402 404402 4420 11354.816 $E [expr $Comp_I*409571722.790] 1; 
element elasticBeamColumn 503104 403104 3140 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 503202 403202 3220 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 503204 403204 3240 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 503302 403302 3320 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 503304 403304 3340 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 503402 403402 3420 14451.584 $E [expr $Comp_I*874085993.760] 1; 
element elasticBeamColumn 502104 402104 2140 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 502202 402202 2220 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 502204 402204 2240 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 502302 402302 2320 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 502304 402304 2340 14451.584 $E [expr $Comp_I*874085993.760] 1; element elasticBeamColumn 502402 402402 2420 14451.584 $E [expr $Comp_I*874085993.760] 1; 

###################################################################################################
#                                           MF BEAM SPRINGS                                       #
###################################################################################################

# Command Syntax 
# Spring_IMK SpringID iNode jNode E fy Ix d htw bftf ry L Ls Lb My PgPye CompositeFLAG MFconnection Units; 

Spring_IMK 905104 514 5140 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5451.995 2725.998 2745.200 754301.959 0.0 $Composite 1 1; Spring_IMK 905202 5220 522 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5451.995 2725.998 2745.200 754301.959 0.0 $Composite 1 1; Spring_IMK 905204 524 5240 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5451.995 2725.998 2745.200 754301.959 0.0 $Composite 1 1; Spring_IMK 905302 5320 532 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5449.455 2724.728 2743.930 754301.959 0.0 $Composite 1 1; Spring_IMK 905304 534 5340 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5449.455 2724.728 2743.930 754301.959 0.0 $Composite 1 1; Spring_IMK 905402 5420 542 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5451.995 2725.998 2745.200 754301.959 0.0 $Composite 1 1; 
Spring_IMK 904104 414 4140 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5451.995 2725.998 2745.200 754301.959 0.0 $Composite 1 1; Spring_IMK 904202 4220 422 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5451.995 2725.998 2745.200 754301.959 0.0 $Composite 1 1; Spring_IMK 904204 424 4240 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5451.995 2725.998 2745.200 754301.959 0.0 $Composite 1 1; Spring_IMK 904302 4320 432 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5449.455 2724.728 2743.930 754301.959 0.0 $Composite 1 1; Spring_IMK 904304 434 4340 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5449.455 2724.728 2743.930 754301.959 0.0 $Composite 1 1; Spring_IMK 904402 4420 442 $E $fy [expr $Comp_I*409571722.790] 462.280 38.700 5.440 42.672 5451.995 2725.998 2745.200 754301.959 0.0 $Composite 1 1; 
Spring_IMK 903104 314 3140 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5429.491 2714.745 2737.580 1230309.160 0.0 $Composite 1 1; Spring_IMK 903202 3220 322 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5429.491 2714.745 2737.580 1230309.160 0.0 $Composite 1 1; Spring_IMK 903204 324 3240 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5429.491 2714.745 2737.580 1230309.160 0.0 $Composite 1 1; Spring_IMK 903302 3320 332 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5426.951 2713.475 2736.310 1230309.160 0.0 $Composite 1 1; Spring_IMK 903304 334 3340 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5426.951 2713.475 2736.310 1230309.160 0.0 $Composite 1 1; Spring_IMK 903402 3420 342 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5429.491 2714.745 2737.580 1230309.160 0.0 $Composite 1 1; 
Spring_IMK 902104 214 2140 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5429.491 2714.745 2737.580 1230309.160 0.0 $Composite 1 1; Spring_IMK 902202 2220 222 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5429.491 2714.745 2737.580 1230309.160 0.0 $Composite 1 1; Spring_IMK 902204 224 2240 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5429.491 2714.745 2737.580 1230309.160 0.0 $Composite 1 1; Spring_IMK 902302 2320 232 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5426.951 2713.475 2736.310 1230309.160 0.0 $Composite 1 1; Spring_IMK 902304 234 2340 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5426.951 2713.475 2736.310 1230309.160 0.0 $Composite 1 1; Spring_IMK 902402 2420 242 $E $fy [expr $Comp_I*874085993.760] 607.060 49.000 6.610 48.768 5429.491 2714.745 2737.580 1230309.160 0.0 $Composite 1 1; 

###################################################################################################
#                                           MF COLUMN SPRINGS                                     #
###################################################################################################

Spring_IMK  905101  405101     511 $E $fy 874085993.7600 607.0600 49.0000 6.6100 48.7680 3537.7200 1768.8600 3537.7200 1243778.1576 0.0170  0 0 1; Spring_IMK  905201  405201     521 $E $fy 986468478.6720 612.1400 45.9000 5.8600 49.5300 3537.7200 1768.8600 3537.7200 1393031.5365 0.0103  0 0 1; Spring_IMK  905301  405301     531 $E $fy 986468478.6720 612.1400 45.9000 5.8600 49.5300 3537.7200 1768.8600 3537.7200 1393031.5365 0.0103  0 0 1; Spring_IMK  905401  405401     541 $E $fy 874085993.7600 607.0600 49.0000 6.6100 48.7680 3537.7200 1768.8600 3537.7200 1243778.1576 0.0170  0 0 1; 
Spring_IMK  904103  404103     413 $E $fy 874085993.7600 607.0600 49.0000 6.6100 48.7680 3537.7200 1768.8600 3537.7200 1243778.1576 0.0170  0 0 1; Spring_IMK  904203  404203     423 $E $fy 986468478.6720 612.1400 45.9000 5.8600 49.5300 3537.7200 1768.8600 3537.7200 1393031.5365 0.0103  0 0 1; Spring_IMK  904303  404303     433 $E $fy 986468478.6720 612.1400 45.9000 5.8600 49.5300 3537.7200 1768.8600 3537.7200 1393031.5365 0.0103  0 0 1; Spring_IMK  904403  404403     443 $E $fy 874085993.7600 607.0600 49.0000 6.6100 48.7680 3537.7200 1768.8600 3537.7200 1243778.1576 0.0170  0 0 1; 
Spring_IMK  904101  404101     411 $E $fy 874085993.7600 607.0600 49.0000 6.6100 48.7680 3537.7200 1768.8600 3537.7200 1243778.1576 0.0644  0 0 1; Spring_IMK  904201  404201     421 $E $fy 986468478.6720 612.1400 45.9000 5.8600 49.5300 3537.7200 1768.8600 3537.7200 1393031.5365 0.0389  0 0 1; Spring_IMK  904301  404301     431 $E $fy 986468478.6720 612.1400 45.9000 5.8600 49.5300 3537.7200 1768.8600 3537.7200 1393031.5365 0.0389  0 0 1; Spring_IMK  904401  404401     441 $E $fy 874085993.7600 607.0600 49.0000 6.6100 48.7680 3537.7200 1768.8600 3537.7200 1243778.1576 0.0644  0 0 1; 
Spring_IMK  903103  403103     313 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3465.3300 1732.6650 3465.3300 1741289.4206 0.0476  0 0 1; Spring_IMK  903203  403203     323 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3465.3300 1732.6650 3465.3300 2599496.3494 0.0224  0 0 1; Spring_IMK  903303  403303     333 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3465.3300 1732.6650 3465.3300 2599496.3494 0.0224  0 0 1; Spring_IMK  903403  403403     343 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3465.3300 1732.6650 3465.3300 1741289.4206 0.0476  0 0 1; 
Spring_IMK  903101  403101     311 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3392.9400 1696.4700 3392.9400 1741289.4206 0.0826  0 0 1; Spring_IMK  903201  403201     321 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3392.9400 1696.4700 3392.9400 2599496.3494 0.0388  0 0 1; Spring_IMK  903301  403301     331 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3392.9400 1696.4700 3392.9400 2599496.3494 0.0388  0 0 1; Spring_IMK  903401  403401     341 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3392.9400 1696.4700 3392.9400 1741289.4206 0.0826  0 0 1; 
Spring_IMK  902103  402103     213 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3392.9400 1696.4700 3392.9400 1741289.4206 0.0826  0 0 1; Spring_IMK  902203  402203     223 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3392.9400 1696.4700 3392.9400 2599496.3494 0.0388  0 0 1; Spring_IMK  902303  402303     233 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3392.9400 1696.4700 3392.9400 2599496.3494 0.0388  0 0 1; Spring_IMK  902403  402403     243 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3392.9400 1696.4700 3392.9400 1741289.4206 0.0826  0 0 1; 
Spring_IMK  902101  402101     211 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3996.4700 1998.2350 3996.4700 1741289.4206 0.1179  0 0 1; Spring_IMK  902201  402201     221 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3996.4700 1998.2350 3996.4700 2599496.3494 0.0554  0 0 1; Spring_IMK  902301  402301     231 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3996.4700 1998.2350 3996.4700 2599496.3494 0.0554  0 0 1; Spring_IMK  902401  402401     241 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3996.4700 1998.2350 3996.4700 1741289.4206 0.1179  0 0 1; 
Spring_IMK  901103     110     113 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3996.4700 1998.2350 3996.4700 1741289.4206 0.1179  0 0 1; Spring_IMK  901203     120     123 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3996.4700 1998.2350 3996.4700 2599496.3494 0.0554  0 0 1; Spring_IMK  901303     130     133 $E $fy 1906339929.2480 627.3800 33.2000 5.9200 76.4540 3996.4700 1998.2350 3996.4700 2599496.3494 0.0554  0 0 1; Spring_IMK  901403     140     143 $E $fy 1248694276.8000 622.3000 39.2000 4.5900 50.5460 3996.4700 1998.2350 3996.4700 1741289.4206 0.1179  0 0 1; 

###################################################################################################
#                                          COLUMN SPLICE SPRINGS                                  #
###################################################################################################

Spring_Rigid 903107 103171 103172; 
Spring_Rigid 903207 103271 103272; 
Spring_Rigid 903307 103371 103372; 
Spring_Rigid 903407 103471 103472; 
Spring_Rigid 903507 103571 103572; 
# Spring_Rigid 903607 103671 103672; 

####################################################################################################
#                                              FLOOR LINKS                                         #
####################################################################################################

# Command Syntax 
# element truss $ElementID $iNode $jNode $Area $matID
element truss 1005 405404 550 $A_Stiff 99;
element truss 1004 404404 450 $A_Stiff 99;
element truss 1003 403404 350 $A_Stiff 99;
element truss 1002 402404 250 $A_Stiff 99;

####################################################################################################
#                                          EGF COLUMNS AND BEAMS                                   #
####################################################################################################

# GRAVITY COLUMNS
element elasticBeamColumn  604500     453     551 100000.0000 $E 100000000.0000 $trans_PDelta;# element elasticBeamColumn  604600     463     561 100000.0000 $E 100000000.0000 $trans_PDelta; 
element elasticBeamColumn  603502  103572     451 100000.0000 $E 100000000.0000 $trans_PDelta;# element elasticBeamColumn  603602  103672     461 100000.0000 $E 100000000.0000 $trans_PDelta; 
element elasticBeamColumn  603501     353  103571 100000.0000 $E 100000000.0000 $trans_PDelta;# element elasticBeamColumn  603601     363  103671 100000.0000 $E 100000000.0000 $trans_PDelta; 
element elasticBeamColumn  602500     253     351 100000.0000 $E 100000000.0000 $trans_PDelta;# element elasticBeamColumn  602600     263     361 100000.0000 $E 100000000.0000 $trans_PDelta; 
element elasticBeamColumn  601500     153     251 100000.0000 $E 100000000.0000 $trans_PDelta;# element elasticBeamColumn  601600     163     261 100000.0000 $E 100000000.0000 $trans_PDelta; 

# GRAVITY BEAMS
# element elasticBeamColumn  505400     554     562 100000.0000 $E 100000000.0000 $trans_PDelta;
# element elasticBeamColumn  504400     454     462 100000.0000 $E 100000000.0000 $trans_PDelta;
# element elasticBeamColumn  503400     354     362 100000.0000 $E 100000000.0000 $trans_PDelta;
# element elasticBeamColumn  502400     254     262 100000.0000 $E 100000000.0000 $trans_PDelta;

# GRAVITY COLUMNS SPRINGS
# Spring_Zero  905501     550     551; Spring_Zero  905601     560     561; 
Spring_Zero  904503     450     453;# Spring_Zero  904603     460     463; 
# Spring_Zero  904501     450     451; Spring_Zero  904601     460     461; 
Spring_Zero  903503     350     353;# Spring_Zero  903603     360     363; 
# Spring_Zero  903501     350     351; Spring_Zero  903601     360     361; 
Spring_Zero  902503     250     253;# Spring_Zero  902603     260     263; 
# Spring_Zero  902501     250     251; Spring_Zero  902601     260     261; 
Spring_Zero  901503     150     153;# Spring_Zero  901603     160     163; 

Spring_Rigid  905501     550     551
Spring_Rigid  904501     450     451
Spring_Rigid  903501     350     351
Spring_Rigid  902501     250     251

# GRAVITY BEAMS SPRINGS
# Spring_Rigid  905504     550     554; Spring_Rigid  905602     560     562; 
# Spring_Rigid  904504     450     454; Spring_Rigid  904602     460     462; 
# Spring_Rigid  903504     350     354; Spring_Rigid  903602     360     362; 
# Spring_Rigid  902504     250     254; Spring_Rigid  902602     260     262; 

###################################################################################################
#                                       BOUNDARY CONDITIONS                                       #
###################################################################################################

# MF SUPPORTS
fix 110 1 1 1; 
fix 120 1 1 1; 
fix 130 1 1 1; 
fix 140 1 1 1; 

# EGF SUPPORTS
fix 150 1 1 0;# fix 160 1 1 0; 

# MF FLOOR MOVEMENT
equalDOF 405104 405204 1; equalDOF 405104 405304 1; equalDOF 405104 405404 1; 
equalDOF 404104 404204 1; equalDOF 404104 404304 1; equalDOF 404104 404404 1; 
equalDOF 403104 403204 1; equalDOF 403104 403304 1; equalDOF 403104 403404 1; 
equalDOF 402104 402204 1; equalDOF 402104 402304 1; equalDOF 402104 402404 1; 

# EGF FLOOR MOVEMENT
# equalDOF 550 560 1;
# equalDOF 450 460 1;
# equalDOF 350 360 1;
# equalDOF 250 260 1;


##################################################################################################
##################################################################################################
                                       puts "Model Built"
##################################################################################################
##################################################################################################

###################################################################################################
#                                             RECORDERS                                           #
###################################################################################################
# delete some recorders
# EIGEN VECTORS
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode1.out -node 402104 403104 404104 405104  -dof 1 "eigen  1";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode2.out -node 402104 403104 404104 405104  -dof 1 "eigen  2";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode3.out -node 402104 403104 404104 405104  -dof 1 "eigen  3";
recorder Node -file $MainFolder/EigenAnalysis/EigenVectorsMode4.out -node 402104 403104 404104 405104  -dof 1 "eigen  4";

# TIME
recorder Node -file $MainFolder/$SubFolder/Time.out  -time -node 110 -dof 1 disp;

# SUPPORT REACTIONS
recorder Node -file $MainFolder/$SubFolder/Support1.out -node     110 -dof 1 2 3 reaction; recorder Node -file $MainFolder/$SubFolder/Support2.out -node     120 -dof 1 2 3 reaction; recorder Node -file $MainFolder/$SubFolder/Support3.out -node     130 -dof 1 2 3 reaction; recorder Node -file $MainFolder/$SubFolder/Support4.out -node     140 -dof 1 2 3 reaction; recorder Node -file $MainFolder/$SubFolder/Support5.out -node     150 -dof 1 2 3 reaction;# recorder Node -file $MainFolder/$SubFolder/Support6.out -node     160 -dof 1 2 3 reaction; 

# FLOOR LATERAL DISPLACEMENT
recorder Node -file $MainFolder/$SubFolder/Disp5_MF.out  -node  405104 -dof 1 disp; 
recorder Node -file $MainFolder/$SubFolder/Disp4_MF.out  -node  404104 -dof 1 disp; 
recorder Node -file $MainFolder/$SubFolder/Disp3_MF.out  -node  403104 -dof 1 disp; 
recorder Node -file $MainFolder/$SubFolder/Disp2_MF.out  -node  402104 -dof 1 disp; 

# STORY DRIFT RATIO
recorder Drift -file $MainFolder/$SubFolder/SDR4_MF.out -iNode  404104 -jNode  405104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR3_MF.out -iNode  403104 -jNode  404104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR2_MF.out -iNode  402104 -jNode  403104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR1_MF.out -iNode     110 -jNode  402104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDRALL_MF.out -iNode     110 -jNode  405104 -dof 1 -perpDirn 2; 

# FLOOR ACCELERATION
recorder Node -file $MainFolder/$SubFolder/RFA5_MF.out -node 405104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA4_MF.out -node 404104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA3_MF.out -node 403104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA2_MF.out -node 402104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA1_MF.out -node 110 -dof 1 accel; 

# FLOOR VELOCITY
recorder Node -file $MainFolder/$SubFolder/RFV5_MF.out -node  405104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV4_MF.out -node  404104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV3_MF.out -node  403104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV2_MF.out -node  402104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV1_MF.out -node     110 -dof 1 vel; 

# COLUMN ELASTIC ELEMENT FORCES
recorder Element -file $MainFolder/$SubFolder/Column41.out -ele  604100 force; recorder Element -file $MainFolder/$SubFolder/Column42.out -ele  604200 force; recorder Element -file $MainFolder/$SubFolder/Column43.out -ele  604300 force; recorder Element -file $MainFolder/$SubFolder/Column44.out -ele  604400 force; recorder Element -file $MainFolder/$SubFolder/Column45.out -ele  604500 force;# recorder Element -file $MainFolder/$SubFolder/Column46.out -ele  604600 force; 
recorder Element -file $MainFolder/$SubFolder/Column31.out -ele  603101 force; recorder Element -file $MainFolder/$SubFolder/Column32.out -ele  603201 force; recorder Element -file $MainFolder/$SubFolder/Column33.out -ele  603301 force; recorder Element -file $MainFolder/$SubFolder/Column34.out -ele  603401 force; recorder Element -file $MainFolder/$SubFolder/Column35.out -ele  603501 force;# recorder Element -file $MainFolder/$SubFolder/Column36.out -ele  603601 force; 
recorder Element -file $MainFolder/$SubFolder/Column21.out -ele  602100 force; recorder Element -file $MainFolder/$SubFolder/Column22.out -ele  602200 force; recorder Element -file $MainFolder/$SubFolder/Column23.out -ele  602300 force; recorder Element -file $MainFolder/$SubFolder/Column24.out -ele  602400 force; recorder Element -file $MainFolder/$SubFolder/Column25.out -ele  602500 force;# recorder Element -file $MainFolder/$SubFolder/Column26.out -ele  602600 force; 
recorder Element -file $MainFolder/$SubFolder/Column11.out -ele  601100 force; recorder Element -file $MainFolder/$SubFolder/Column12.out -ele  601200 force; recorder Element -file $MainFolder/$SubFolder/Column13.out -ele  601300 force; recorder Element -file $MainFolder/$SubFolder/Column14.out -ele  601400 force; recorder Element -file $MainFolder/$SubFolder/Column15.out -ele  601500 force;# recorder Element -file $MainFolder/$SubFolder/Column16.out -ele  601600 force; 

# COLUMN SPRINGS FORCES
recorder Element -file $MainFolder/$SubFolder/ColSpring51B_F.out -ele  905101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring52B_F.out -ele  905201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring53B_F.out -ele  905301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring54B_F.out -ele  905401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring41T_F.out -ele  904103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring42T_F.out -ele  904203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring43T_F.out -ele  904303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring44T_F.out -ele  904403 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_F.out -ele  904101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring42B_F.out -ele  904201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring43B_F.out -ele  904301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring44B_F.out -ele  904401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_F.out -ele  903103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring32T_F.out -ele  903203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring33T_F.out -ele  903303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring34T_F.out -ele  903403 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_F.out -ele  903101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring32B_F.out -ele  903201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring33B_F.out -ele  903301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring34B_F.out -ele  903401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_F.out -ele  902103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring22T_F.out -ele  902203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring23T_F.out -ele  902303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring24T_F.out -ele  902403 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_F.out -ele  902101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring22B_F.out -ele  902201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring23B_F.out -ele  902301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring24B_F.out -ele  902401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_F.out -ele  901103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring12T_F.out -ele  901203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring13T_F.out -ele  901303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring14T_F.out -ele  901403 force; 

# COLUMN SPRINGS ROTATIONS
recorder Element -file $MainFolder/$SubFolder/ColSpring51B_D.out -ele  905101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring52B_D.out -ele  905201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring53B_D.out -ele  905301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring54B_D.out -ele  905401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring41T_D.out -ele  904103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring42T_D.out -ele  904203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring43T_D.out -ele  904303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring44T_D.out -ele  904403 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_D.out -ele  904101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring42B_D.out -ele  904201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring43B_D.out -ele  904301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring44B_D.out -ele  904401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_D.out -ele  903103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring32T_D.out -ele  903203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring33T_D.out -ele  903303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring34T_D.out -ele  903403 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_D.out -ele  903101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring32B_D.out -ele  903201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring33B_D.out -ele  903301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring34B_D.out -ele  903401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_D.out -ele  902103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring22T_D.out -ele  902203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring23T_D.out -ele  902303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring24T_D.out -ele  902403 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_D.out -ele  902101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring22B_D.out -ele  902201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring23B_D.out -ele  902301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring24B_D.out -ele  902401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_D.out -ele  901103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring12T_D.out -ele  901203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring13T_D.out -ele  901303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring14T_D.out -ele  901403 deformation; 

# BEAM SPRINGS FORCES
recorder Element -file $MainFolder/$SubFolder/BeamSpring51R_F.out -ele   905104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring52L_F.out -ele   905202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring52R_F.out -ele   905204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring53L_F.out -ele   905302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring53R_F.out -ele   905304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring54L_F.out -ele   905402 force; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_F.out -ele   904104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_F.out -ele   904202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_F.out -ele   904204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_F.out -ele   904302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_F.out -ele   904304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_F.out -ele   904402 force; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_F.out -ele   903104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_F.out -ele   903202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_F.out -ele   903204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_F.out -ele   903302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_F.out -ele   903304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_F.out -ele   903402 force; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_F.out -ele   902104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_F.out -ele   902202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_F.out -ele   902204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_F.out -ele   902302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_F.out -ele   902304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_F.out -ele   902402 force; 

# BEAM SPRINGS ROTATIONS
recorder Element -file $MainFolder/$SubFolder/BeamSpring51R_D.out -ele   905104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring52L_D.out -ele   905202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring52R_D.out -ele   905204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring53L_D.out -ele   905302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring53R_D.out -ele   905304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring54L_D.out -ele   905402 deformation; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_D.out -ele   904104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_D.out -ele   904202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_D.out -ele   904204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_D.out -ele   904302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_D.out -ele   904304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_D.out -ele   904402 deformation; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_D.out -ele   903104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_D.out -ele   903202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_D.out -ele   903204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_D.out -ele   903302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_D.out -ele   903304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_D.out -ele   903402 deformation; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_D.out -ele   902104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_D.out -ele   902202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_D.out -ele   902204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_D.out -ele   902302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_D.out -ele   902304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_D.out -ele   902402 deformation; 

# PZ SPRING MOMENT
recorder Element -file $MainFolder/$SubFolder/PZ51_F.out -ele  905100 force; recorder Element -file $MainFolder/$SubFolder/PZ52_F.out -ele  905200 force; recorder Element -file $MainFolder/$SubFolder/PZ53_F.out -ele  905300 force; recorder Element -file $MainFolder/$SubFolder/PZ54_F.out -ele  905400 force; 
recorder Element -file $MainFolder/$SubFolder/PZ41_F.out -ele  904100 force; recorder Element -file $MainFolder/$SubFolder/PZ42_F.out -ele  904200 force; recorder Element -file $MainFolder/$SubFolder/PZ43_F.out -ele  904300 force; recorder Element -file $MainFolder/$SubFolder/PZ44_F.out -ele  904400 force; 
recorder Element -file $MainFolder/$SubFolder/PZ31_F.out -ele  903100 force; recorder Element -file $MainFolder/$SubFolder/PZ32_F.out -ele  903200 force; recorder Element -file $MainFolder/$SubFolder/PZ33_F.out -ele  903300 force; recorder Element -file $MainFolder/$SubFolder/PZ34_F.out -ele  903400 force; 
recorder Element -file $MainFolder/$SubFolder/PZ21_F.out -ele  902100 force; recorder Element -file $MainFolder/$SubFolder/PZ22_F.out -ele  902200 force; recorder Element -file $MainFolder/$SubFolder/PZ23_F.out -ele  902300 force; recorder Element -file $MainFolder/$SubFolder/PZ24_F.out -ele  902400 force; 

# PZ SPRING ROTATION
recorder Element -file $MainFolder/$SubFolder/PZ51_D.out -ele  905100 deformation; recorder Element -file $MainFolder/$SubFolder/PZ52_D.out -ele  905200 deformation; recorder Element -file $MainFolder/$SubFolder/PZ53_D.out -ele  905300 deformation; recorder Element -file $MainFolder/$SubFolder/PZ54_D.out -ele  905400 deformation; 
recorder Element -file $MainFolder/$SubFolder/PZ41_D.out -ele  904100 deformation; recorder Element -file $MainFolder/$SubFolder/PZ42_D.out -ele  904200 deformation; recorder Element -file $MainFolder/$SubFolder/PZ43_D.out -ele  904300 deformation; recorder Element -file $MainFolder/$SubFolder/PZ44_D.out -ele  904400 deformation; 
recorder Element -file $MainFolder/$SubFolder/PZ31_D.out -ele  903100 deformation; recorder Element -file $MainFolder/$SubFolder/PZ32_D.out -ele  903200 deformation; recorder Element -file $MainFolder/$SubFolder/PZ33_D.out -ele  903300 deformation; recorder Element -file $MainFolder/$SubFolder/PZ34_D.out -ele  903400 deformation; 
recorder Element -file $MainFolder/$SubFolder/PZ21_D.out -ele  902100 deformation; recorder Element -file $MainFolder/$SubFolder/PZ22_D.out -ele  902200 deformation; recorder Element -file $MainFolder/$SubFolder/PZ23_D.out -ele  902300 deformation; recorder Element -file $MainFolder/$SubFolder/PZ24_D.out -ele  902400 deformation; 

###################################################################################################
#                                              NODAL MASS                                         #
###################################################################################################

# change node mass at axis-4
set g 9810.00;
mass 405104 0.0042  1.e-9 1.e-9; mass 405204 0.0041  1.e-9 1.e-9; mass 405304 0.0041  1.e-9 1.e-9; mass 405404 0.0042  1.e-9 1.e-9; mass 550 [expr 0.0326 * 2]  1.e-9 1.e-9;# mass 560 0.0326  1.e-9 1.e-9; 
mass 404104 0.0152  1.e-9 1.e-9; mass 404204 0.0126  1.e-9 1.e-9; mass 404304 0.0126  1.e-9 1.e-9; mass 404404 0.0152  1.e-9 1.e-9; mass 450 [expr 0.1341 * 2]  1.e-9 1.e-9;# mass 460 0.1341  1.e-9 1.e-9; 
mass 403104 0.0152  1.e-9 1.e-9; mass 403204 0.0126  1.e-9 1.e-9; mass 403304 0.0126  1.e-9 1.e-9; mass 403404 0.0152  1.e-9 1.e-9; mass 350 [expr 0.1341 * 2]  1.e-9 1.e-9;# mass 360 0.1341  1.e-9 1.e-9; 
mass 402104 0.0154  1.e-9 1.e-9; mass 402204 0.0130  1.e-9 1.e-9; mass 402304 0.0130  1.e-9 1.e-9; mass 402404 0.0154  1.e-9 1.e-9; mass 250 [expr 0.1348 * 2]  1.e-9 1.e-9;# mass 260 0.1348  1.e-9 1.e-9; 

constraints Plain;

###################################################################################################
#                                        EIGEN VALUE ANALYSIS                                     #
###################################################################################################

set pi [expr 2.0*asin(1.0)];
set nEigen 4;
set lambdaN [eigen [expr $nEigen]];
set lambda1 [lindex $lambdaN 0];
set lambda2 [lindex $lambdaN 1];
set lambda3 [lindex $lambdaN 2];
set lambda4 [lindex $lambdaN 3];
set w1 [expr pow($lambda1,0.5)];
set w2 [expr pow($lambda2,0.5)];
set w3 [expr pow($lambda3,0.5)];
set w4 [expr pow($lambda4,0.5)];
set T1 [expr round(2.0*$pi/$w1 *1000.)/1000.];
set T2 [expr round(2.0*$pi/$w2 *1000.)/1000.];
set T3 [expr round(2.0*$pi/$w3 *1000.)/1000.];
set T4 [expr round(2.0*$pi/$w4 *1000.)/1000.];
puts "T1 = $T1 s";
puts "T2 = $T2 s";
puts "T3 = $T3 s";
# cd $RFpath;
# cd "Results"
# cd "EigenAnalysis"
set fileX [open "$MainFolder/EigenAnalysis/EigenPeriod.out" w];
puts $fileX $T1;puts $fileX $T2;puts $fileX $T3;puts $fileX $T4;close $fileX;
# cd $MainDir;

# constraints Plain;
# algorithm Newton;
# integrator LoadControl 1;
# analysis Static;
# analyze 1;

###################################################################################################
###################################################################################################
									puts "Eigen Analysis Done"
###################################################################################################
###################################################################################################

###################################################################################################
#                                      STATIC GRAVITY ANALYSIS                                    #
###################################################################################################

pattern Plain 100 Linear {

	# MF COLUMNS LOADS
	load 405103 0. -67.933 0.; 	    load 405203 0. -45.289 0.; 	    load 405303 0. -45.289 0.; 	    load 405403 0. -67.933 0.; 
	load 404103 0. -188.863 0.; 	load 404203 0. -125.909 0.; 	load 404303 0. -125.909 0.; 	load 404403 0. -188.863 0.; 
	load 403103 0. -188.863 0.; 	load 403203 0. -125.909 0.; 	load 403303 0. -125.909 0.; 	load 403403 0. -188.863 0.; 
	load 402103 0. -190.592 0.; 	load 402203 0. -127.061 0.; 	load 402303 0. -127.061 0.; 	load 402403 0. -190.592 0.; 

	# EGF COLUMN LOADS
	load 550 0. [expr -502.554600  * 2] 0.;# 	load 560 0. -502.554600  0.; 
	load 450 0. [expr -1535.072625 * 2] 0.;# 	load 460 0. -1535.072625 0.; 
	load 350 0. [expr -1535.072625 * 2] 0.;# 	load 360 0. -1535.072625 0.; 
	load 250 0. [expr -1539.107775 * 2] 0.;# 	load 260 0. -1539.107775 0.; 

}

# Conversion Parameters
constraints Plain;
numberer RCM;
system BandGeneral;
test NormDispIncr 1.0e-5 60 ;
algorithm Newton;
integrator LoadControl 0.1;
analysis Static;
analyze 10;

loadConst -time 0.0;

###################################################################################################
###################################################################################################
										puts "Gravity Done"
###################################################################################################
###################################################################################################

# puts "Seismic Weight= 12344.453 kN";
# puts "Seismic Mass=  1.048 kN.sec2/mm";

if {$ShowAnimation == 1} {
	DisplayModel3D DeformedShape 5.00 100 100  1600 1000;
}

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
# beam and column elements
region 1 -ele  604100 604200 604300 604400 603102 603202 603302 603402 603101 603201 603301 603401 602100 602200 602300 602400 601100 601200 601300 601400 505100 505200 505300 504100 504200 504300 503100 503200 503300 502100 502200 502300  -rayleigh 0.0 0.0 $a1_mod 0.0;
region 4 -ele  5022001 5022002 5032001 5032002 5042001 5042002 5052001 5052002 -rayleigh 0.0 0.0 $a1_mod 0.0;  # The divided beams
# mass point
region 2 -node  402104 402204 402304 402404 250 260 403104 403204 403304 403404 350 360 404104 404204 404304 404404 450 460 405104 405204 405304 405404 550 560  -rayleigh $a0 0.0 0.0 0.0;
# Plastic hinge elements
region 3 -eleRange  900000  999999 -rayleigh 0.0 0.0 [expr $a1_mod/10] 0.0;

# rayleigh $a0 0 $a1 0;

# GROUND MOTION ACCELERATION FILE INPUT
set AccelSeries "Series -dt $GMdt -filePath $GMFile -factor  [expr $EqSF * $g]";
pattern UniformExcitation  200 1 -accel $AccelSeries

set MF_FloorNodes [list  402104 403104 404104 405104 ];
set EGF_FloorNodes [list  402104 403104 404104 405104 ];
set GMduration [expr $GMdt*$GMpoints];
# set FVduration 30;
set NumSteps [expr round(($GMduration + $FVduration)/$GMdt)];	# number of steps in analysis
set totTime [expr $GMdt*$NumSteps];                            # Total time of analysis
set dtAnalysis [expr 1.000000*$GMdt];                             	# dt of Analysis

DynamicAnalysisCollapseSolverX  $GMdt	$dtAnalysis	$totTime $NStory	 0.15   $MF_FloorNodes	$EGF_FloorNodes	4300.00 4000.00 1 $StartTime $MaxRunTime $GMname;

###################################################################################################
###################################################################################################
							puts "Ground Motion Done. End Time: [getTime]"
###################################################################################################
###################################################################################################
}


# add codes for pushover analysis
###################################################################################################
#											Pushover Analysis                     		          #
###################################################################################################
if {$PO==1} {

# read modal shape and define story mass
set m4 [expr 0.0042 + 0.0041 + 0.0041 + 0.0042 + 0.0326 + 0.0326]; 
set m3 [expr 0.0152 + 0.0126 + 0.0126 + 0.0152 + 0.1341 + 0.1341]; 
set m2 [expr 0.0152 + 0.0126 + 0.0126 + 0.0152 + 0.1341 + 0.1341]; 
set m1 [expr 0.0154 + 0.0130 + 0.0130 + 0.0154 + 0.1348 + 0.1348]; 

# set m1 0.329; set m2 0.3238; set m3 0.3238; set m4 0.3066;
set file [open "$MainFolder/EigenAnalysis/EigenVectorsMode1.out" r]
set first_line [gets $file]
close $file
set mode_list [split $first_line]
set F1 [expr $m1 * [lindex $mode_list 0]]
set F2 [expr $m2 * [lindex $mode_list 1]]
set F3 [expr $m3 * [lindex $mode_list 2]]
set F4 [expr $m4 * [lindex $mode_list 3]]

# Create Load Pattern
pattern Plain 222 Linear {
	load 405103 $F4 0.0 0.0
	load 404103 $F3 0.0 0.0
	load 403103 $F2 0.0 0.0
	load 402103 $F1 0.0 0.0
};

# Displacement Control Parameters
set CtrlNode 405104;
set CtrlDOF 1;
set Dmax [expr 0.100*$Floor5];
set Dincr [expr 0.5];

set Nsteps [expr int($Dmax/$Dincr)];
set ok 0;
set controlDisp 0.0;
source LibAnalysisStaticParameters.tcl;
source SolutionAlgorithm.tcl;

###################################################################################################
###################################################################################################
										puts "Pushover complete"
###################################################################################################
###################################################################################################
}




wipe all;
