
wipe all;
model basic -ndm 2 -ndf 3;


# Basic model variables
set maxRunTime 600.0;  # $$$
set EQ 1;  # $$$
set PO 0;  # $$$
set ShowAnimation 1;  # $$$
set MPCO 0;  # $$$

# Ground motion information
set MainFolder "H:/RCF_results/test/4SMRF";  # $$$
set GMname "th5";  # $$$
set SubFolder "th5";  # $$$
set GMdt 0.01;  # $$$
set GMpoints 5590;  # $$$
set GMduration 55.89;  # $$$
set FVduration 30;  # $$$
set EqSF 2.0;  # $$$
set GMFile "F:/MRF/GMs/$GMname.th";  # $$$
set subroutines "F:/MRF/subroutines";  # $$$
set temp "F:/MRF/temp";  # $$$

# Sourcing subroutines
cd $subroutines;
source DisplayModel3D.tcl;
source DisplayPlane.tcl;
source Spring_Zero.tcl;
source Spring_Rigid.tcl;
source PanelZone.tcl
source BeamHinge.tcl
source ColumnHinge.tcl
source TimeHistorySolver.tcl;
source PushoverAnalysis.tcl;
source ConstructPanel_Cross.tcl;
source ModSpring_IMK_RC.tcl

# Results folders
file mkdir $MainFolder;
file mkdir $MainFolder/$SubFolder;

# Basic parameters
set NStory 6;
set NBay 3;
set E   206000;
set Es  206000;
set mu  0.300; 
set fy  [expr 400.0 *   1.2];  # (PEER/ATC-72-1) Calculate the expected strength
set fc  [expr 20.1 * 1.25];  # (PEER/ATC-72-1)
set Ec  [expr 4733.0 * pow($fc, 0.5)];  # (PEER/ATC-72-1)
uniaxialMaterial Elastic 9 1.e-9;
uniaxialMaterial Elastic 99 1.e12;
geomTransf Linear 1;
geomTransf PDelta 2;
geomTransf Corotational 3;
set trans_selected 2;
set A_Stiff 1.e8;
set I_Stiff 1.e13;
set fy_beam 345.00;
set fy_column 345.00;

# Building geometry
set Floor1 0.0;
set Floor2 4300.0;
set Floor3 8300.0;
set Floor4 12300.0;
set Floor5 16300.0;
set Floor6 20300.0;
set Floor7 24300.0;

set Axis1 0.0;
set Axis2 6000.0;
set Axis3 9000.0;
set Axis4 15000.0;
set Axis5 21000.0;

set HBuilding 24300.0;
set story_heights [list 4300 4000 4000 4000 4000 4000];

set I_col1to3 [expr 1.0 / 12 * 600 * 600 ** 3];
set I_col4to6 [expr 1.0 / 12 * 550 * 550 ** 3];
set I_beam_E  [expr 1.0 / 12 * 250 * 550 ** 3];
set I_beam_I  [expr 1.0 / 12 * 250 * 400 ** 3];

set A_col1to3 [expr 600.0 * 600.0];
set A_col4to6 [expr 550.0 * 550.0];
set A_beam_E  [expr 250.0 * 550.0];
set A_beam_I  [expr 250.0 * 400.0];

# story mass
# Without infilled wall
set m1 83.61;
set m2 82.53;
set m3 82.53;
set m4 80.23;
set m5 80.23;
set m6 82.16;

# Axial compression ratio
set PPy_6I 0.08;  set PPy_6E 0.07;
set PPy_5I 0.17;  set PPy_5E 0.15;
set PPy_4I 0.26;  set PPy_4E 0.24;
set PPy_3I 0.29;  set PPy_3E 0.28;
set PPy_2I 0.37;  set PPy_2E 0.36;
set PPy_1I 0.45;  set PPy_1E 0.44;
proc PPy_Overturn {PPy} {return [expr $PPy * 1.00]};  # Consideration of the PPy enlargement due to overturnning effect
set PPy_6I [PPy_Overturn $PPy_6I];  set PPy_6E [PPy_Overturn $PPy_6E];
set PPy_5I [PPy_Overturn $PPy_5I];  set PPy_5E [PPy_Overturn $PPy_5E];
set PPy_4I [PPy_Overturn $PPy_4I];  set PPy_4E [PPy_Overturn $PPy_4E];
set PPy_3I [PPy_Overturn $PPy_3I];  set PPy_3E [PPy_Overturn $PPy_3E];
set PPy_2I [PPy_Overturn $PPy_2I];  set PPy_2E [PPy_Overturn $PPy_2E];
set PPy_1I [PPy_Overturn $PPy_1I];  set PPy_1E [PPy_Overturn $PPy_1E];

# effective stiffness
# beam
set EIEg_beam 0.35;
set EIEg_beam 1;  # TODO test for not considering stiffness reduction
# colomu
set EIEg_col_1I [expr 0.75 * pow(0.1 + $PPy_1I, 0.8)]; set EIEg_col_1E [expr 0.75 * pow(0.1 + $PPy_1E, 0.8)];  # story 1
set EIEg_col_2I [expr 0.75 * pow(0.1 + $PPy_2I, 0.8)]; set EIEg_col_2E [expr 0.75 * pow(0.1 + $PPy_2E, 0.8)];  # story 2
set EIEg_col_3I [expr 0.75 * pow(0.1 + $PPy_3I, 0.8)]; set EIEg_col_3E [expr 0.75 * pow(0.1 + $PPy_3E, 0.8)];  # story 3
set EIEg_col_4I [expr 0.75 * pow(0.1 + $PPy_4I, 0.8)]; set EIEg_col_4E [expr 0.75 * pow(0.1 + $PPy_4E, 0.8)];  # story 4
set EIEg_col_5I [expr 0.75 * pow(0.1 + $PPy_5I, 0.8)]; set EIEg_col_5E [expr 0.75 * pow(0.1 + $PPy_5E, 0.8)];  # story 5
set EIEg_col_6I [expr 0.75 * pow(0.1 + $PPy_6I, 0.8)]; set EIEg_col_6E [expr 0.75 * pow(0.1 + $PPy_6E, 0.8)];  # story 6
proc EI_range {EIEg} {
	set result $EIEg
	if {$result < 0.2} {set result 0.2}
	if {$result > 0.6} {set result 0.6}
	set result 1.0;  # TODO test for not considering stiffness reduction
	return $result
}
set EIEg_col_1I [EI_range $EIEg_col_1I]; set EIEg_col_1E [EI_range $EIEg_col_1E];
set EIEg_col_2I [EI_range $EIEg_col_2I]; set EIEg_col_2E [EI_range $EIEg_col_2E];
set EIEg_col_3I [EI_range $EIEg_col_3I]; set EIEg_col_3E [EI_range $EIEg_col_3E];
set EIEg_col_4I [EI_range $EIEg_col_4I]; set EIEg_col_4E [EI_range $EIEg_col_4E];
set EIEg_col_5I [EI_range $EIEg_col_5I]; set EIEg_col_5E [EI_range $EIEg_col_5E];
set EIEg_col_6I [EI_range $EIEg_col_6I]; set EIEg_col_6E [EI_range $EIEg_col_6E];

# site class II
# beam hinge parameters
# E - External
# M - Middle
# I - Internal
set sf_beam 1.2
set sf_col  1.2
#                     fc  Ec  fy  Es  b   h  d1  s  rho_C    rho_T   rho_I  rho_SH  a_sl  PPc Units Length  EIyEIg type_ name
# floor 2
set IMKbeam_2E [list $fc $Ec $fy $Es 250 550 25 100 0.0152 	0.0067 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_2I [list $fc $Ec $fy $Es 250 550 25 100 0.0152 	0.0067 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_2M [list $fc $Ec $fy $Es 250 400 25 100 0.0180 	0.0153 	0.0000 	0.0040   1    0.0  1    2400  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
# floor 3
set IMKbeam_3E [list $fc $Ec $fy $Es 250 550 25 100 0.0170 	0.0080 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_3I [list $fc $Ec $fy $Es 250 550 25 100 0.0170 	0.0080 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_3M [list $fc $Ec $fy $Es 250 400 25 100 0.0260 	0.0178 	0.0000 	0.0040   1    0.0  1    2400  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
# floor 4
set IMKbeam_4E [list $fc $Ec $fy $Es 250 550 25 100 0.0159 	0.0072 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_4I [list $fc $Ec $fy $Es 250 550 25 100 0.0159 	0.0072 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_4M [list $fc $Ec $fy $Es 250 400 25 100 0.0189 	0.0160 	0.0000 	0.0040   1    0.0  1    2400  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
# floor 5
set IMKbeam_5E [list $fc $Ec $fy $Es 250 550 25 100 0.0135 	0.0054 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_5I [list $fc $Ec $fy $Es 250 550 25 100 0.0135 	0.0054 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_5M [list $fc $Ec $fy $Es 250 400 25 100 0.0151 	0.0106 	0.0000 	0.0040   1    0.0  1    2450  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
# floor 6
set IMKbeam_6E [list $fc $Ec $fy $Es 250 550 25 100 0.0096 	0.0030 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_6I [list $fc $Ec $fy $Es 250 550 25 100 0.0096 	0.0030 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_6M [list $fc $Ec $fy $Es 250 400 25 100 0.0093 	0.0072 	0.0000 	0.0040   1    0.0  1    2450  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
# floor 783
set IMKbeam_7E [list $fc $Ec $fy $Es 250 550 25 100 0.0064 	0.0030 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_7I [list $fc $Ec $fy $Es 250 550 25 100 0.0064 	0.0030 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];
set IMKbeam_7M [list $fc $Ec $fy $Es 250 400 25 100 0.0059 	0.0030 	0.0000 	0.0040   1    0.0  1    2450  $EIEg_beam 1   ""  [expr $sf_beam * 1.0]];

# column hinge parameters
#                     fc  Ec  fy  Es  b   h  d1  s  rho_C    rho_T   rho_I  rho_SH  a_sl  PPc Units Length  EIyEIg
# story 1
set IMKcol_1I  [list $fc $Ec $fy $Es 600 600 25 100 0.0058 	0.0058 	0.0058 	0.0034   1 $PPy_1I 1    3750 $EIEg_col_1I 2   ""  [expr $sf_col * 0.73]];
set IMKcol_1E  [list $fc $Ec $fy $Es 600 600 25 100 0.0058 	0.0058 	0.0058 	0.0034   1 $PPy_1E 1    3750 $EIEg_col_1E 2   ""  [expr $sf_col * 0.73]];
# story 2
set IMKcol_2I  [list $fc $Ec $fy $Es 600 600 25 100 0.0029 	0.0029 	0.0029 	0.0034   1 $PPy_2I 1    3450 $EIEg_col_2I 2   ""  [expr $sf_col * 1.2]];
set IMKcol_2E  [list $fc $Ec $fy $Es 600 600 25 100 0.0029 	0.0029 	0.0029 	0.0034   1 $PPy_2E 1    3450 $EIEg_col_2E 2   ""  [expr $sf_col * 1.2]];
# story 3
set IMKcol_3I  [list $fc $Ec $fy $Es 600 600 25 100 0.0030 	0.0030 	0.0030 	0.0034   1 $PPy_3I 1    3450 $EIEg_col_3I 2   ""  [expr $sf_col * 1.1]];
set IMKcol_3E  [list $fc $Ec $fy $Es 600 600 25 100 0.0030 	0.0030 	0.0030 	0.0034   1 $PPy_3E 1    3450 $EIEg_col_3E 2   ""  [expr $sf_col * 1.1]];
# story 4
set IMKcol_4I  [list $fc $Ec $fy $Es 550 550 25 100 0.0042 	0.0042 	0.0042 	0.0037   1 $PPy_4I 1    3450 $EIEg_col_4I 2   ""  [expr $sf_col * 1.0]];
set IMKcol_4E  [list $fc $Ec $fy $Es 550 550 25 100 0.0042 	0.0042 	0.0042 	0.0037   1 $PPy_4E 1    3450 $EIEg_col_4E 2   ""  [expr $sf_col * 1.0]];
# story 5
set IMKcol_5I  [list $fc $Ec $fy $Es 550 550 25 100 0.0032 	0.0032 	0.0032 	0.0037   1 $PPy_5I 1    3450 $EIEg_col_5I 2   ""  [expr $sf_col * 1.0]];
set IMKcol_5E  [list $fc $Ec $fy $Es 550 550 25 100 0.0032 	0.0032 	0.0032 	0.0037   1 $PPy_5E 1    3450 $EIEg_col_5E 2   ""  [expr $sf_col * 1.0]];
# story 6
set IMKcol_6I  [list $fc $Ec $fy $Es 550 550 25 100 0.0028 	0.0028 	0.0028 	0.0037   1 $PPy_6I 1    3450 $EIEg_col_6I 2   ""  [expr $sf_col * 1.0]];
set IMKcol_6E  [list $fc $Ec $fy $Es 550 550 25 100 0.0028 	0.0028 	0.0028 	0.0037   1 $PPy_6E 1    3450 $EIEg_col_6E 2   ""  [expr $sf_col * 1.0]];

####################################################################################################
#                                                  NODES                                           #
####################################################################################################


# Support nodes
node 10010100 $Axis1 $Floor1;
node 10010200 $Axis2 $Floor1;
node 10010300 $Axis3 $Floor1;
node 10010400 $Axis4 $Floor1;

# Moment frame column nodes
node 10010101 $Axis1 $Floor1;  node 10010201 $Axis2 $Floor1;  node 10010301 $Axis3 $Floor1;  node 10010401 $Axis4 $Floor1;
node 10020102 $Axis1 [expr $Floor2 - 550.0/2];  node 10020202 $Axis2 [expr $Floor2 - 550.0/2];  node 10020302 $Axis3 [expr $Floor2 - 550.0/2];  node 10020402 $Axis4 [expr $Floor2 - 550.0/2];
node 10020101 $Axis1 [expr $Floor2 + 550.0/2];  node 10020201 $Axis2 [expr $Floor2 + 550.0/2];  node 10020301 $Axis3 [expr $Floor2 + 550.0/2];  node 10020401 $Axis4 [expr $Floor2 + 550.0/2];
node 10030102 $Axis1 [expr $Floor3 - 550.0/2];  node 10030202 $Axis2 [expr $Floor3 - 550.0/2];  node 10030302 $Axis3 [expr $Floor3 - 550.0/2];  node 10030402 $Axis4 [expr $Floor3 - 550.0/2];
node 10030101 $Axis1 [expr $Floor3 + 550.0/2];  node 10030201 $Axis2 [expr $Floor3 + 550.0/2];  node 10030301 $Axis3 [expr $Floor3 + 550.0/2];  node 10030401 $Axis4 [expr $Floor3 + 550.0/2];
node 10040102 $Axis1 [expr $Floor4 - 550.0/2];  node 10040202 $Axis2 [expr $Floor4 - 550.0/2];  node 10040302 $Axis3 [expr $Floor4 - 550.0/2];  node 10040402 $Axis4 [expr $Floor4 - 550.0/2];
node 10040101 $Axis1 [expr $Floor4 + 550.0/2];  node 10040201 $Axis2 [expr $Floor4 + 550.0/2];  node 10040301 $Axis3 [expr $Floor4 + 550.0/2];  node 10040401 $Axis4 [expr $Floor4 + 550.0/2];
node 10050102 $Axis1 [expr $Floor5 - 550.0/2];  node 10050202 $Axis2 [expr $Floor5 - 550.0/2];  node 10050302 $Axis3 [expr $Floor5 - 550.0/2];  node 10050402 $Axis4 [expr $Floor5 - 550.0/2];
node 10050101 $Axis1 [expr $Floor5 + 550.0/2];  node 10050201 $Axis2 [expr $Floor5 + 550.0/2];  node 10050301 $Axis3 [expr $Floor5 + 550.0/2];  node 10050401 $Axis4 [expr $Floor5 + 550.0/2];
node 10060102 $Axis1 [expr $Floor6 - 550.0/2];  node 10060202 $Axis2 [expr $Floor6 - 550.0/2];  node 10060302 $Axis3 [expr $Floor6 - 550.0/2];  node 10060402 $Axis4 [expr $Floor6 - 550.0/2];
node 10060101 $Axis1 [expr $Floor6 + 550.0/2];  node 10060201 $Axis2 [expr $Floor6 + 550.0/2];  node 10060301 $Axis3 [expr $Floor6 + 550.0/2];  node 10060401 $Axis4 [expr $Floor6 + 550.0/2];
node 10070102 $Axis1 [expr $Floor7 - 550.0/2];  node 10070202 $Axis2 [expr $Floor7 - 550.0/2];  node 10070302 $Axis3 [expr $Floor7 - 550.0/2];  node 10070402 $Axis4 [expr $Floor7 - 550.0/2];

# Moment frame beam nodes
node 10020104 [expr $Axis1 + 300.0] $Floor2;  node 10020205 [expr $Axis2 - 300.0] $Floor2;  node 10020204 [expr $Axis2 + 300.0] $Floor2;  node 10020305 [expr $Axis3 - 300.0] $Floor2;  node 10020304 [expr $Axis3 + 300.0] $Floor2;  node 10020405 [expr $Axis4 - 300.0] $Floor2;
node 10030104 [expr $Axis1 + 300.0] $Floor3;  node 10030205 [expr $Axis2 - 300.0] $Floor3;  node 10030204 [expr $Axis2 + 300.0] $Floor3;  node 10030305 [expr $Axis3 - 300.0] $Floor3;  node 10030304 [expr $Axis3 + 300.0] $Floor3;  node 10030405 [expr $Axis4 - 300.0] $Floor3;
node 10040104 [expr $Axis1 + 300.0] $Floor4;  node 10040205 [expr $Axis2 - 300.0] $Floor4;  node 10040204 [expr $Axis2 + 300.0] $Floor4;  node 10040305 [expr $Axis3 - 300.0] $Floor4;  node 10040304 [expr $Axis3 + 300.0] $Floor4;  node 10040405 [expr $Axis4 - 300.0] $Floor4;
node 10050104 [expr $Axis1 + 275.0] $Floor5;  node 10050205 [expr $Axis2 - 275.0] $Floor5;  node 10050204 [expr $Axis2 + 275.0] $Floor5;  node 10050305 [expr $Axis3 - 275.0] $Floor5;  node 10050304 [expr $Axis3 + 275.0] $Floor5;  node 10050405 [expr $Axis4 - 275.0] $Floor5;
node 10060104 [expr $Axis1 + 275.0] $Floor6;  node 10060205 [expr $Axis2 - 275.0] $Floor6;  node 10060204 [expr $Axis2 + 275.0] $Floor6;  node 10060305 [expr $Axis3 - 275.0] $Floor6;  node 10060304 [expr $Axis3 + 275.0] $Floor6;  node 10060405 [expr $Axis4 - 275.0] $Floor6;
node 10070104 [expr $Axis1 + 275.0] $Floor7;  node 10070205 [expr $Axis2 - 275.0] $Floor7;  node 10070204 [expr $Axis2 + 275.0] $Floor7;  node 10070305 [expr $Axis3 - 275.0] $Floor7;  node 10070304 [expr $Axis3 + 275.0] $Floor7;  node 10070405 [expr $Axis4 - 275.0] $Floor7;


###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

set n 10.;

# Column elements
element elasticBeamColumn 10010101 10010101 10020102 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_1E] 2;  element elasticBeamColumn 10010201 10010201 10020202 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_1I] 2;  element elasticBeamColumn 10010301 10010301 10020302 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_1I] 2;  element elasticBeamColumn 10010401 10010401 10020402 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_1E] 2;
element elasticBeamColumn 10020101 10020101 10030102 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_2E] 2;  element elasticBeamColumn 10020201 10020201 10030202 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_2I] 2;  element elasticBeamColumn 10020301 10020301 10030302 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_2I] 2;  element elasticBeamColumn 10020401 10020401 10030402 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_2E] 2;
element elasticBeamColumn 10030101 10030101 10040102 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_3E] 2;  element elasticBeamColumn 10030201 10030201 10040202 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_3I] 2;  element elasticBeamColumn 10030301 10030301 10040302 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_3I] 2;  element elasticBeamColumn 10030401 10030401 10040402 $A_col1to3 $Ec [expr ($n+1)/$n*$I_col1to3*$EIEg_col_3E] 2;
element elasticBeamColumn 10040101 10040101 10050102 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_4E] 2;  element elasticBeamColumn 10040201 10040201 10050202 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_4I] 2;  element elasticBeamColumn 10040301 10040301 10050302 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_4I] 2;  element elasticBeamColumn 10040401 10040401 10050402 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_4E] 2;
element elasticBeamColumn 10050101 10050101 10060102 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_5E] 2;  element elasticBeamColumn 10050201 10050201 10060202 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_5I] 2;  element elasticBeamColumn 10050301 10050301 10060302 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_5I] 2;  element elasticBeamColumn 10050401 10050401 10060402 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_5E] 2;
element elasticBeamColumn 10060101 10060101 10070102 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_6E] 2;  element elasticBeamColumn 10060201 10060201 10070202 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_6I] 2;  element elasticBeamColumn 10060301 10060301 10070302 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_6I] 2;  element elasticBeamColumn 10060401 10060401 10070402 $A_col4to6 $Ec [expr ($n+1)/$n*$I_col4to6*$EIEg_col_6E] 2;

# Beam elements
element elasticBeamColumn 10020104 10020104 10020205 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;  element elasticBeamColumn 10020204 10020204 10020305 $A_beam_I $Ec [expr ($n+1)/$n*$I_beam_I*$EIEg_beam] 2;  element elasticBeamColumn 10020304 10020304 10020405 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;
element elasticBeamColumn 10030104 10030104 10030205 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;  element elasticBeamColumn 10030204 10030204 10030305 $A_beam_I $Ec [expr ($n+1)/$n*$I_beam_I*$EIEg_beam] 2;  element elasticBeamColumn 10030304 10030304 10030405 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;
element elasticBeamColumn 10040104 10040104 10040205 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;  element elasticBeamColumn 10040204 10040204 10040305 $A_beam_I $Ec [expr ($n+1)/$n*$I_beam_I*$EIEg_beam] 2;  element elasticBeamColumn 10040304 10040304 10040405 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;
element elasticBeamColumn 10050104 10050104 10050205 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;  element elasticBeamColumn 10050204 10050204 10050305 $A_beam_I $Ec [expr ($n+1)/$n*$I_beam_I*$EIEg_beam] 2;  element elasticBeamColumn 10050304 10050304 10050405 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;
element elasticBeamColumn 10060104 10060104 10060205 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;  element elasticBeamColumn 10060204 10060204 10060305 $A_beam_I $Ec [expr ($n+1)/$n*$I_beam_I*$EIEg_beam] 2;  element elasticBeamColumn 10060304 10060304 10060405 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;
element elasticBeamColumn 10070104 10070104 10070205 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;  element elasticBeamColumn 10070204 10070204 10070305 $A_beam_I $Ec [expr ($n+1)/$n*$I_beam_I*$EIEg_beam] 2;  element elasticBeamColumn 10070304 10070304 10070405 $A_beam_E $Ec [expr ($n+1)/$n*$I_beam_E*$EIEg_beam] 2;

# Panel zones
# PanelNone Floor Axis X Y E mu fy_column A_stiff I_stiff         d_col d_beam  tp    tf    bf  transfTag type_ position check ""
PanelZone 2 1 $Axis1 $Floor2 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.00 13.97 24.89 228.60 2 2 "L";  PanelZone 2 2 $Axis2 $Floor2 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.0 21.87 24.89 228.60 2 2 "I";  PanelZone 2 3 $Axis3 $Floor2 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.0 21.87 24.89 228.60 2 2 "I";  PanelZone 2 4 $Axis4 $Floor2 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.0 13.97 24.89 228.60 2 2 "R";
PanelZone 3 1 $Axis1 $Floor3 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.00 13.97 24.89 228.60 2 2 "L";  PanelZone 3 2 $Axis2 $Floor3 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.0 21.87 24.89 228.60 2 2 "I";  PanelZone 3 3 $Axis3 $Floor3 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.0 21.87 24.89 228.60 2 2 "I";  PanelZone 3 4 $Axis4 $Floor3 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.0 13.97 24.89 228.60 2 2 "R";
PanelZone 4 1 $Axis1 $Floor4 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.00 13.97 24.89 228.60 2 2 "L";  PanelZone 4 2 $Axis2 $Floor4 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.0 21.87 24.89 228.60 2 2 "I";  PanelZone 4 3 $Axis3 $Floor4 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.0 21.87 24.89 228.60 2 2 "I";  PanelZone 4 4 $Axis4 $Floor4 $Ec $mu $fy_column $A_Stiff $I_Stiff 600.00 550.0 13.97 24.89 228.60 2 2 "R";
PanelZone 5 1 $Axis1 $Floor5 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.00 10.92 14.99 178.82 2 2 "L";  PanelZone 5 2 $Axis2 $Floor5 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.0 18.82 14.99 178.82 2 2 "I";  PanelZone 5 3 $Axis3 $Floor5 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.0 18.82 14.99 178.82 2 2 "I";  PanelZone 5 4 $Axis4 $Floor5 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.0 10.92 14.99 178.82 2 2 "R";
PanelZone 6 1 $Axis1 $Floor6 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.00 10.92 14.99 178.82 2 2 "L";  PanelZone 6 2 $Axis2 $Floor6 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.0 10.92 14.99 178.82 2 2 "I";  PanelZone 6 3 $Axis3 $Floor6 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.0 10.92 14.99 178.82 2 2 "I";  PanelZone 6 4 $Axis4 $Floor6 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.0 10.92 14.99 178.82 2 2 "R";
PanelZone 7 1 $Axis1 $Floor7 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.00 10.92 14.99 178.82 2 2 "LT";  PanelZone 7 2 $Axis2 $Floor7 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.0 10.92 14.99 178.82 2 2 "T";  PanelZone 7 3 $Axis3 $Floor7 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.0 10.92 14.99 178.82 2 2 "T";  PanelZone 7 4 $Axis4 $Floor7 $Ec $mu $fy_column $A_Stiff $I_Stiff 550.00 550.0 10.92 14.99 178.82 2 2 "RT";

# Beam hinges
# BeamHinge SpringID NodeI NodeJ E fy_beam Ix d htw bftf ry L Ls Lb My type_ {check ""}
ModSpring_IMK_RC 10020109 11020104 10020104 {*}$IMKbeam_2E;  ModSpring_IMK_RC 10020210 10020205 11020202 {*}$IMKbeam_2I;  ModSpring_IMK_RC 10020209 11020204 10020204 {*}$IMKbeam_2M;  ModSpring_IMK_RC 10020310 10020305 11020302 {*}$IMKbeam_2M;  ModSpring_IMK_RC 10020309 11020304 10020304 {*}$IMKbeam_2I;  ModSpring_IMK_RC 10020410 10020405 11020402 {*}$IMKbeam_2E;
ModSpring_IMK_RC 10030109 11030104 10030104 {*}$IMKbeam_3E;  ModSpring_IMK_RC 10030210 10030205 11030202 {*}$IMKbeam_3I;  ModSpring_IMK_RC 10030209 11030204 10030204 {*}$IMKbeam_3M;  ModSpring_IMK_RC 10030310 10030305 11030302 {*}$IMKbeam_3M;  ModSpring_IMK_RC 10030309 11030304 10030304 {*}$IMKbeam_3I;  ModSpring_IMK_RC 10030410 10030405 11030402 {*}$IMKbeam_3E;
ModSpring_IMK_RC 10040109 11040104 10040104 {*}$IMKbeam_4E;  ModSpring_IMK_RC 10040210 10040205 11040202 {*}$IMKbeam_4I;  ModSpring_IMK_RC 10040209 11040204 10040204 {*}$IMKbeam_4M;  ModSpring_IMK_RC 10040310 10040305 11040302 {*}$IMKbeam_4M;  ModSpring_IMK_RC 10040309 11040304 10040304 {*}$IMKbeam_4I;  ModSpring_IMK_RC 10040410 10040405 11040402 {*}$IMKbeam_4E;
ModSpring_IMK_RC 10050109 11050104 10050104 {*}$IMKbeam_5E;  ModSpring_IMK_RC 10050210 10050205 11050202 {*}$IMKbeam_5I;  ModSpring_IMK_RC 10050209 11050204 10050204 {*}$IMKbeam_5M;  ModSpring_IMK_RC 10050310 10050305 11050302 {*}$IMKbeam_5M;  ModSpring_IMK_RC 10050309 11050304 10050304 {*}$IMKbeam_5I;  ModSpring_IMK_RC 10050410 10050405 11050402 {*}$IMKbeam_5E;
ModSpring_IMK_RC 10060109 11060104 10060104 {*}$IMKbeam_6E;  ModSpring_IMK_RC 10060210 10060205 11060202 {*}$IMKbeam_6I;  ModSpring_IMK_RC 10060209 11060204 10060204 {*}$IMKbeam_6M;  ModSpring_IMK_RC 10060310 10060305 11060302 {*}$IMKbeam_6M;  ModSpring_IMK_RC 10060309 11060304 10060304 {*}$IMKbeam_6I;  ModSpring_IMK_RC 10060410 10060405 11060402 {*}$IMKbeam_6E;
ModSpring_IMK_RC 10070109 11070104 10070104 {*}$IMKbeam_7E;  ModSpring_IMK_RC 10070210 10070205 11070202 {*}$IMKbeam_7I;  ModSpring_IMK_RC 10070209 11070204 10070204 {*}$IMKbeam_7M;  ModSpring_IMK_RC 10070310 10070305 11070302 {*}$IMKbeam_7M;  ModSpring_IMK_RC 10070309 11070304 10070304 {*}$IMKbeam_7I;  ModSpring_IMK_RC 10070410 10070405 11070402 {*}$IMKbeam_7E;

# Column hinges
# Column SpringID NodeI NodeJ E Ix d htw ry L Lb My PPy SF_PPy pinned check ""
ModSpring_IMK_RC 10010107 10010100 10010101 {*}$IMKcol_1E;  ModSpring_IMK_RC 10010207 10010200 10010201 {*}$IMKcol_1I;  ModSpring_IMK_RC 10010307 10010300 10010301 {*}$IMKcol_1I;  ModSpring_IMK_RC 10010407 10010400 10010401 {*}$IMKcol_1E;
ModSpring_IMK_RC 10020108 10020102 11020101 {*}$IMKcol_1E;  ModSpring_IMK_RC 10020208 10020202 11020201 {*}$IMKcol_1I;  ModSpring_IMK_RC 10020308 10020302 11020301 {*}$IMKcol_1I;  ModSpring_IMK_RC 10020408 10020402 11020401 {*}$IMKcol_1E;
ModSpring_IMK_RC 10020107 11020103 10020101 {*}$IMKcol_2E;  ModSpring_IMK_RC 10020207 11020203 10020201 {*}$IMKcol_2I;  ModSpring_IMK_RC 10020307 11020303 10020301 {*}$IMKcol_2I;  ModSpring_IMK_RC 10020407 11020403 10020401 {*}$IMKcol_2E;
ModSpring_IMK_RC 10030108 10030102 11030101 {*}$IMKcol_2E;  ModSpring_IMK_RC 10030208 10030202 11030201 {*}$IMKcol_2I;  ModSpring_IMK_RC 10030308 10030302 11030301 {*}$IMKcol_2I;  ModSpring_IMK_RC 10030408 10030402 11030401 {*}$IMKcol_2E;
ModSpring_IMK_RC 10030107 11030103 10030101 {*}$IMKcol_3E;  ModSpring_IMK_RC 10030207 11030203 10030201 {*}$IMKcol_3I;  ModSpring_IMK_RC 10030307 11030303 10030301 {*}$IMKcol_3I;  ModSpring_IMK_RC 10030407 11030403 10030401 {*}$IMKcol_3E;
ModSpring_IMK_RC 10040108 10040102 11040101 {*}$IMKcol_3E;  ModSpring_IMK_RC 10040208 10040202 11040201 {*}$IMKcol_3I;  ModSpring_IMK_RC 10040308 10040302 11040301 {*}$IMKcol_3I;  ModSpring_IMK_RC 10040408 10040402 11040401 {*}$IMKcol_3E;
ModSpring_IMK_RC 10040107 11040103 10040101 {*}$IMKcol_4E;  ModSpring_IMK_RC 10040207 11040203 10040201 {*}$IMKcol_4I;  ModSpring_IMK_RC 10040307 11040303 10040301 {*}$IMKcol_4I;  ModSpring_IMK_RC 10040407 11040403 10040401 {*}$IMKcol_4E;
ModSpring_IMK_RC 10050108 10050102 11050101 {*}$IMKcol_4E;  ModSpring_IMK_RC 10050208 10050202 11050201 {*}$IMKcol_4I;  ModSpring_IMK_RC 10050308 10050302 11050301 {*}$IMKcol_4I;  ModSpring_IMK_RC 10050408 10050402 11050401 {*}$IMKcol_4E;
ModSpring_IMK_RC 10050107 11050103 10050101 {*}$IMKcol_5E;  ModSpring_IMK_RC 10050207 11050203 10050201 {*}$IMKcol_5I;  ModSpring_IMK_RC 10050307 11050303 10050301 {*}$IMKcol_5I;  ModSpring_IMK_RC 10050407 11050403 10050401 {*}$IMKcol_5E;
ModSpring_IMK_RC 10060108 10060102 11060101 {*}$IMKcol_5E;  ModSpring_IMK_RC 10060208 10060202 11060201 {*}$IMKcol_5I;  ModSpring_IMK_RC 10060308 10060302 11060301 {*}$IMKcol_5I;  ModSpring_IMK_RC 10060408 10060402 11060401 {*}$IMKcol_5E;
ModSpring_IMK_RC 10060107 11060103 10060101 {*}$IMKcol_6E;  ModSpring_IMK_RC 10060207 11060203 10060201 {*}$IMKcol_6I;  ModSpring_IMK_RC 10060307 11060303 10060301 {*}$IMKcol_6I;  ModSpring_IMK_RC 10060407 11060403 10060401 {*}$IMKcol_6E;
ModSpring_IMK_RC 10070108 10070102 11070101 {*}$IMKcol_6E;  ModSpring_IMK_RC 10070208 10070202 11070201 {*}$IMKcol_6I;  ModSpring_IMK_RC 10070308 10070302 11070301 {*}$IMKcol_6I;  ModSpring_IMK_RC 10070408 10070402 11070401 {*}$IMKcol_6E;



###################################################################################################
#                                       BOUNDARY CONDITIONS                                       #
###################################################################################################

# Support
fix 10010100 1 1 1;
fix 10010200 1 1 1;
fix 10010300 1 1 1;
fix 10010400 1 1 1;

# Rigid diaphragm
equalDOF 11020200 11020100 1;  equalDOF 11020200 11020300 1;  equalDOF 11020200 11020400 1;
equalDOF 11030200 11030100 1;  equalDOF 11030200 11030300 1;  equalDOF 11030200 11030400 1;
equalDOF 11040200 11040100 1;  equalDOF 11040200 11040300 1;  equalDOF 11040200 11040400 1;
equalDOF 11050200 11050100 1;  equalDOF 11050200 11050300 1;  equalDOF 11050200 11050400 1;
equalDOF 11060200 11060100 1;  equalDOF 11060200 11060300 1;  equalDOF 11060200 11060400 1;
equalDOF 11070200 11070100 1;  equalDOF 11070200 11070300 1;  equalDOF 11070200 11070400 1;

# Time
recorder Node -file $MainFolder/$SubFolder/Time.out -time -node 10010100 -dof 1 disp;

# Support reactions
recorder Node -file $MainFolder/$SubFolder/Support1.out -node 10010100 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support2.out -node 10010200 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support3.out -node 10010300 -dof 1 2 3 reaction;
recorder Node -file $MainFolder/$SubFolder/Support4.out -node 10010400 -dof 1 2 3 reaction;

# Story drift ratio
recorder Drift -file $MainFolder/$SubFolder/SDR1.out -iNode 10010100 -jNode 11020200 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR2.out -iNode 11020200 -jNode 11030200 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR3.out -iNode 11030200 -jNode 11040200 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR4.out -iNode 11040200 -jNode 11050200 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR5.out -iNode 11050200 -jNode 11060200 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR6.out -iNode 11060200 -jNode 11070200 -dof 1 -perpDirn 2;
recorder Drift -file $MainFolder/$SubFolder/SDR_Roof.out -iNode 10010100 -jNode 11070200 -dof 1 -perpDirn 2;

# Floor acceleration
recorder Node -file $MainFolder/$SubFolder/RFA1.out -node 10010100 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA2.out -node 11020200 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA3.out -node 11030200 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA4.out -node 11040200 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA5.out -node 11050200 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA6.out -node 11060200 -dof 1 accel;
recorder Node -file $MainFolder/$SubFolder/RFA7.out -node 11070200 -dof 1 accel;

# Floor velocity
recorder Node -file $MainFolder/$SubFolder/RFV1.out -node 10010100 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV2.out -node 11020200 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV3.out -node 11030200 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV4.out -node 11040200 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV5.out -node 11050200 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV6.out -node 11060200 -dof 1 vel;
recorder Node -file $MainFolder/$SubFolder/RFV7.out -node 11070200 -dof 1 vel;

# Floor displacement
recorder Node -file $MainFolder/$SubFolder/Disp1.out -node 10010100 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp2.out -node 11020200 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp3.out -node 11030200 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp4.out -node 11040200 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp5.out -node 11050200 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp6.out -node 11060200 -dof 1 disp;
recorder Node -file $MainFolder/$SubFolder/Disp7.out -node 11070200 -dof 1 disp;

# Shear forces
recorder Element -file $MainFolder/$SubFolder/Shear1_1.out -ele 10010101 force;  recorder Element -file $MainFolder/$SubFolder/Shear1_2.out -ele 10010201 force;  recorder Element -file $MainFolder/$SubFolder/Shear1_3.out -ele 10010301 force;  recorder Element -file $MainFolder/$SubFolder/Shear1_4.out -ele 10010401 force;
recorder Element -file $MainFolder/$SubFolder/Shear2_1.out -ele 10020101 force;  recorder Element -file $MainFolder/$SubFolder/Shear2_2.out -ele 10020201 force;  recorder Element -file $MainFolder/$SubFolder/Shear2_3.out -ele 10020301 force;  recorder Element -file $MainFolder/$SubFolder/Shear2_4.out -ele 10020401 force;
recorder Element -file $MainFolder/$SubFolder/Shear3_1.out -ele 10030101 force;  recorder Element -file $MainFolder/$SubFolder/Shear3_2.out -ele 10030201 force;  recorder Element -file $MainFolder/$SubFolder/Shear3_3.out -ele 10030301 force;  recorder Element -file $MainFolder/$SubFolder/Shear3_4.out -ele 10030401 force;
recorder Element -file $MainFolder/$SubFolder/Shear4_1.out -ele 10040101 force;  recorder Element -file $MainFolder/$SubFolder/Shear4_2.out -ele 10040201 force;  recorder Element -file $MainFolder/$SubFolder/Shear4_3.out -ele 10040301 force;  recorder Element -file $MainFolder/$SubFolder/Shear4_4.out -ele 10040401 force;
recorder Element -file $MainFolder/$SubFolder/Shear5_1.out -ele 10050101 force;  recorder Element -file $MainFolder/$SubFolder/Shear5_2.out -ele 10050201 force;  recorder Element -file $MainFolder/$SubFolder/Shear5_3.out -ele 10050301 force;  recorder Element -file $MainFolder/$SubFolder/Shear5_4.out -ele 10050401 force;
recorder Element -file $MainFolder/$SubFolder/Shear6_1.out -ele 10060101 force;  recorder Element -file $MainFolder/$SubFolder/Shear6_2.out -ele 10060201 force;  recorder Element -file $MainFolder/$SubFolder/Shear6_3.out -ele 10060301 force;  recorder Element -file $MainFolder/$SubFolder/Shear6_4.out -ele 10060401 force;

# Column springs
recorder Element -file $MainFolder/$SubFolder/ColSpring1_1T.out -ele 10010107 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring1_2T.out -ele 10010207 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring1_3T.out -ele 10010307 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring1_4T.out -ele 10010407 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring2_1B.out -ele 10020108 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring2_2B.out -ele 10020208 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring2_3B.out -ele 10020308 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring2_4B.out -ele 10020408 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring2_1T.out -ele 10020107 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring2_2T.out -ele 10020207 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring2_3T.out -ele 10020307 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring2_4T.out -ele 10020407 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring3_1B.out -ele 10030108 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring3_2B.out -ele 10030208 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring3_3B.out -ele 10030308 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring3_4B.out -ele 10030408 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring3_1T.out -ele 10030107 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring3_2T.out -ele 10030207 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring3_3T.out -ele 10030307 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring3_4T.out -ele 10030407 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring4_1B.out -ele 10040108 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring4_2B.out -ele 10040208 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring4_3B.out -ele 10040308 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring4_4B.out -ele 10040408 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring4_1T.out -ele 10040107 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring4_2T.out -ele 10040207 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring4_3T.out -ele 10040307 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring4_4T.out -ele 10040407 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring5_1B.out -ele 10050108 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring5_2B.out -ele 10050208 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring5_3B.out -ele 10050308 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring5_4B.out -ele 10050408 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring5_1T.out -ele 10050107 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring5_2T.out -ele 10050207 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring5_3T.out -ele 10050307 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring5_4T.out -ele 10050407 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring6_1B.out -ele 10060108 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring6_2B.out -ele 10060208 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring6_3B.out -ele 10060308 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring6_4B.out -ele 10060408 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring6_1T.out -ele 10060107 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring6_2T.out -ele 10060207 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring6_3T.out -ele 10060307 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring6_4T.out -ele 10060407 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/ColSpring7_1B.out -ele 10070108 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring7_2B.out -ele 10070208 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring7_3B.out -ele 10070308 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/ColSpring7_4B.out -ele 10070408 material 3 stressStrain;

# Beam springs
recorder Element -file $MainFolder/$SubFolder/BeamSpring2_1R.out -ele 10020109 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring2_2L.out -ele 10020210 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring2_2R.out -ele 10020209 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring2_3L.out -ele 10020310 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring2_3R.out -ele 10020309 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring2_4L.out -ele 10020410 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/BeamSpring3_1R.out -ele 10030109 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring3_2L.out -ele 10030210 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring3_2R.out -ele 10030209 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring3_3L.out -ele 10030310 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring3_3R.out -ele 10030309 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring3_4L.out -ele 10030410 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/BeamSpring4_1R.out -ele 10040109 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring4_2L.out -ele 10040210 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring4_2R.out -ele 10040209 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring4_3L.out -ele 10040310 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring4_3R.out -ele 10040309 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring4_4L.out -ele 10040410 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/BeamSpring5_1R.out -ele 10050109 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring5_2L.out -ele 10050210 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring5_2R.out -ele 10050209 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring5_3L.out -ele 10050310 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring5_3R.out -ele 10050309 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring5_4L.out -ele 10050410 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/BeamSpring6_1R.out -ele 10060109 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring6_2L.out -ele 10060210 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring6_2R.out -ele 10060209 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring6_3L.out -ele 10060310 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring6_3R.out -ele 10060309 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring6_4L.out -ele 10060410 material 3 stressStrain;
recorder Element -file $MainFolder/$SubFolder/BeamSpring7_1R.out -ele 10070109 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring7_2L.out -ele 10070210 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring7_2R.out -ele 10070209 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring7_3L.out -ele 10070310 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring7_3R.out -ele 10070309 material 3 stressStrain;  recorder Element -file $MainFolder/$SubFolder/BeamSpring7_4L.out -ele 10070410 material 3 stressStrain;

# MPCO recorder
if {$MPCO == 1} {
    recorder mpco $MainFolder$SubFolder/result.mpco -N displacement acceleration modesOfVibration -E material.stress material.strain;
}



# ---------------------- TMIW ---------------------------------
# Material
uniaxialMaterial Concrete02 101 -2.322  -0.0008 -0.5073 -0.0083;  # wall at story 1
uniaxialMaterial Concrete02 102 -2.5157 -0.0008 -0.4996 -0.0084;  # wall at story 2
uniaxialMaterial Concrete02 103 -2.4973 -0.0008 -0.4795 -0.0084;  # wall at story 3
uniaxialMaterial Concrete02 104 -2.5343 -0.0008 -0.4887 -0.0084;  # wall at story 4
uniaxialMaterial Concrete02 105 -2.5267 -0.0008 -0.4807 -0.0084;  # wall at story 5
uniaxialMaterial Concrete02 106 -2.5175 -0.0008 -0.4719 -0.0084;  # wall at story 6

# Effective area
set wall_A1 1615.6e2;
set wall_A2 1367.3e2;
set wall_A3 1367.3e2;
set wall_A4 1343.4e2;
set wall_A5 1343.4e2;
set wall_A6 1343.4e2;

# Elements / \ / \
# element truss 101 10010100 11020200 $wall_A1 101; element truss 102 10010200 11020100 $wall_A1 101;  element truss 103 10010300 11020400 $wall_A1 101;  element truss 104 10010400 11020300 $wall_A1 101; 
element truss 201 11020100 11030200 $wall_A2 102; element truss 202 11020200 11030100 $wall_A2 102;  element truss 203 11020300 11030400 $wall_A2 102;  element truss 204 11020400 11030300 $wall_A2 102; 
element truss 301 11030100 11040200 $wall_A3 103; element truss 302 11030200 11040100 $wall_A3 103;  element truss 303 11030300 11040400 $wall_A3 103;  element truss 304 11030400 11040300 $wall_A3 103; 
element truss 401 11040100 11050200 $wall_A4 104; element truss 402 11040200 11050100 $wall_A4 104;  element truss 403 11040300 11050400 $wall_A4 104;  element truss 404 11040400 11050300 $wall_A4 104; 
element truss 501 11050100 11060200 $wall_A5 105; element truss 502 11050200 11060100 $wall_A5 105;  element truss 503 11050300 11060400 $wall_A5 105;  element truss 504 11050400 11060300 $wall_A5 105; 
element truss 601 11060100 11070200 $wall_A6 106; element truss 602 11060200 11070100 $wall_A6 106;  element truss 603 11060300 11070400 $wall_A6 106;  element truss 604 11060400 11070300 $wall_A6 106; 

# Masses (Each wall 3.813 t (1st story) or 3.509 t (2-6th story))
set m_wall_1 3.813;
set m_wall_2 3.509;
mass 11020100 [expr $m_wall_1/2] 1.e-9 1.e-9; mass 11020200 [expr $m_wall_1/2] 1.e-9 1.e-9; mass 11020300 [expr $m_wall_1/2] 1.e-9 1.e-9; mass 11020400 [expr $m_wall_1/2] 1.e-9 1.e-9; 
mass 11030100 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11030200 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11030300 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11030400 [expr $m_wall_2/2] 1.e-9 1.e-9; 
mass 11040100 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11040200 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11040300 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11040400 [expr $m_wall_2/2] 1.e-9 1.e-9; 
mass 11050100 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11050200 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11050300 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11050400 [expr $m_wall_2/2] 1.e-9 1.e-9; 
mass 11060100 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11060200 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11060300 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11060400 [expr $m_wall_2/2] 1.e-9 1.e-9; 
mass 11070100 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11070200 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11070300 [expr $m_wall_2/2] 1.e-9 1.e-9; mass 11070400 [expr $m_wall_2/2] 1.e-9 1.e-9; 

# Recorders / \ / \
#
recorder Element -file $MainFolder/$SubFolder/Wall1_1.out -ele 101 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall1_2.out -ele 102 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall1_3.out -ele 103 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall1_4.out -ele 104 material stressStrain;
recorder Element -file $MainFolder/$SubFolder/Wall2_1.out -ele 201 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall2_2.out -ele 202 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall2_3.out -ele 203 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall2_4.out -ele 204 material stressStrain;
recorder Element -file $MainFolder/$SubFolder/Wall3_1.out -ele 301 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall3_2.out -ele 302 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall3_3.out -ele 303 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall3_4.out -ele 304 material stressStrain;
recorder Element -file $MainFolder/$SubFolder/Wall4_1.out -ele 401 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall4_2.out -ele 402 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall4_3.out -ele 403 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall4_4.out -ele 404 material stressStrain;
recorder Element -file $MainFolder/$SubFolder/Wall5_1.out -ele 501 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall5_2.out -ele 502 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall5_3.out -ele 503 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall5_4.out -ele 504 material stressStrain;
recorder Element -file $MainFolder/$SubFolder/Wall6_1.out -ele 601 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall6_2.out -ele 602 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall6_3.out -ele 603 material stressStrain;  recorder Element -file $MainFolder/$SubFolder/Wall6_4.out -ele 604 material stressStrain;





###################################################################################################
#                                              NODAL MASS                                         #
###################################################################################################

set g 9810.00;
# point mass
set m1_ [expr $m1 / 4.0];
set m2_ [expr $m2 / 4.0];
set m3_ [expr $m3 / 4.0];
set m4_ [expr $m4 / 4.0];
set m5_ [expr $m5 / 4.0];
set m6_ [expr $m6 / 4.0];
mass 11070100 $m6_  1.e-9 1.e-9; mass 11060200 $m6_  1.e-9 1.e-9; mass 11070300 $m6_  1.e-9 1.e-9; mass 11070400 $m6_  1.e-9 1.e-9;
mass 11060100 $m5_  1.e-9 1.e-9; mass 11050200 $m5_  1.e-9 1.e-9; mass 11060300 $m5_  1.e-9 1.e-9; mass 11060400 $m5_  1.e-9 1.e-9;
mass 11050100 $m4_  1.e-9 1.e-9; mass 11040200 $m4_  1.e-9 1.e-9; mass 11050300 $m4_  1.e-9 1.e-9; mass 11050400 $m4_  1.e-9 1.e-9;
mass 11040100 $m3_  1.e-9 1.e-9; mass 11040200 $m3_  1.e-9 1.e-9; mass 11040300 $m3_  1.e-9 1.e-9; mass 11040400 $m3_  1.e-9 1.e-9;
mass 11030100 $m2_  1.e-9 1.e-9; mass 11030200 $m2_  1.e-9 1.e-9; mass 11030300 $m2_  1.e-9 1.e-9; mass 11030400 $m2_  1.e-9 1.e-9;
mass 11020100 $m1_  1.e-9 1.e-9; mass 11020200 $m1_  1.e-9 1.e-9; mass 11020300 $m1_  1.e-9 1.e-9; mass 11020400 $m1_  1.e-9 1.e-9;



set pi [expr 2.0*asin(1.0)];
set nEigen 6;
set lambdaN [eigen [expr $nEigen]];
set lambda1 [lindex $lambdaN 0];
set lambda2 [lindex $lambdaN 1];
set lambda3 [lindex $lambdaN 2];
set lambda4 [lindex $lambdaN 3];
set lambda5 [lindex $lambdaN 4];
set lambda6 [lindex $lambdaN 5];
set w1 [expr pow($lambda1,0.5)];
set w2 [expr pow($lambda2,0.5)];
set w3 [expr pow($lambda3,0.5)];
set w4 [expr pow($lambda4,0.5)];
set w5 [expr pow($lambda5,0.5)];
set w6 [expr pow($lambda6,0.5)];
set T1 [expr round(2.0*$pi/$w1 *1000.)/1000.];
set T2 [expr round(2.0*$pi/$w2 *1000.)/1000.];
set T3 [expr round(2.0*$pi/$w3 *1000.)/1000.];
set T4 [expr round(2.0*$pi/$w4 *1000.)/1000.];
set T5 [expr round(2.0*$pi/$w5 *1000.)/1000.];
set T6 [expr round(2.0*$pi/$w6 *1000.)/1000.];
puts "T1 = $T1 s";
puts "T2 = $T2 s";
puts "T3 = $T3 s";

set mode [list]
for {set i 1} {$i <= $NStory} {incr i} {
# set MF_FloorNodes  [list 402104 403104 404104 405104 406104 407104 ];

    lappend mode [expr [nodeEigenvector 11020200 $i 1]]
    lappend mode [expr [nodeEigenvector 11030200 $i 1]]
    lappend mode [expr [nodeEigenvector 11040200 $i 1]]
    lappend mode [expr [nodeEigenvector 11050200 $i 1]]
    lappend mode [expr [nodeEigenvector 11060200 $i 1]]
    lappend mode [expr [nodeEigenvector 11070200 $i 1]]
    set file_mode [open "$MainFolder/$SubFolder/mode$i.out" w]
    foreach val $mode {puts $file_mode $val}
    close $file_mode
    if {$i == 1} {set mode_list $mode}
    set mode [list]
};

set file_T [open "$MainFolder/$SubFolder/Period.out" w];
puts $file_T $T1;
puts $file_T $T2;
puts $file_T $T3;
puts $file_T $T4;
close $file_T;


pattern Plain 100 Linear {

	# MF COLUMNS LOADS
	set scale 1.0;
	# set scale 1.2;
	load 11020101 0. [expr -1.e4*$m6_*$scale] 0.; 	load 11020201 0. [expr -1.e4*$m6_*$scale] 0.; 	load 11020301 0. [expr -1.e4*$m6_*$scale] 0.; 	load 11020401 0. [expr -1.e4*$m6_*$scale] 0.; 
	load 11030101 0. [expr -1.e4*$m5_*$scale] 0.; 	load 11030201 0. [expr -1.e4*$m5_*$scale] 0.; 	load 11030301 0. [expr -1.e4*$m5_*$scale] 0.; 	load 11030401 0. [expr -1.e4*$m5_*$scale] 0.; 
	load 11040101 0. [expr -1.e4*$m4_*$scale] 0.; 	load 11040201 0. [expr -1.e4*$m4_*$scale] 0.; 	load 11040301 0. [expr -1.e4*$m4_*$scale] 0.; 	load 11040401 0. [expr -1.e4*$m4_*$scale] 0.; 
	load 11050101 0. [expr -1.e4*$m3_*$scale] 0.; 	load 11050201 0. [expr -1.e4*$m3_*$scale] 0.; 	load 11050301 0. [expr -1.e4*$m3_*$scale] 0.; 	load 11050401 0. [expr -1.e4*$m3_*$scale] 0.; 
	load 11060101 0. [expr -1.e4*$m2_*$scale] 0.; 	load 11060201 0. [expr -1.e4*$m2_*$scale] 0.; 	load 11060301 0. [expr -1.e4*$m2_*$scale] 0.; 	load 11060401 0. [expr -1.e4*$m2_*$scale] 0.; 
	load 11070101 0. [expr -1.e4*$m1_*$scale] 0.; 	load 11070201 0. [expr -1.e4*$m1_*$scale] 0.; 	load 11070301 0. [expr -1.e4*$m1_*$scale] 0.; 	load 11070401 0. [expr -1.e4*$m1_*$scale] 0.; 
	# Note: All gravity loads are multiplied by 1.2, since the isolated middle 2D frame from the 3D frame bear load of G_floor*2/8, not just G_floor/5. So (G_floor*2/8)/(G_floor/5) = 1.2
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


if {$ShowAnimation == 1} {DisplayModel3D DeformedShape 5.00 100 100 1000 1600};
set MF_FloorNodes [list 11020200 11030200 11040200 11050200 11060200 11070200];

if {$EQ==1} {

# Rayleigh Damping
    set zeta 0.05;
    set a0 [expr $zeta*2.0*$w1*$w3/($w1 + $w3)];
    set a1 [expr $zeta*2.0/($w1 + $w3)];
    rayleigh $a0 0.0 $a1 0.0;

	# GROUND MOTION ACCELERATION FILE INPUT
    set AccelSeries "Series -dt $GMdt -filePath $GMFile -factor [expr $EqSF * $g]";
    pattern UniformExcitation 200 1 -accel $AccelSeries;
    set totTime [expr $GMduration + $FVduration];
    set CollapseDrift 0.15;  # $$$
    set MaxAnalysisDrift 0.5;
    set result [TimeHistorySolver $GMdt $GMduration $story_heights $MF_FloorNodes $CollapseDrift $MaxAnalysisDrift $GMname $maxRunTime $temp];
    set status [lindex $result 0];
    set controlled_time [lindex $result 1];
    puts "Running status: $status";
    puts "Controlled time: $controlled_time";

}

if {$PO==1} {


set F1 [expr $m1 * [lindex $mode_list 0]]
set F2 [expr $m2 * [lindex $mode_list 1]]
set F3 [expr $m3 * [lindex $mode_list 2]]
set F4 [expr $m4 * [lindex $mode_list 3]]
set F5 [expr $m5 * [lindex $mode_list 4]]
set F6 [expr $m6 * [lindex $mode_list 5]]

# Create Load Pattern
pattern Plain 222 Linear {
	load 11070200 $F6 0.0 0.0
	load 11060200 $F5 0.0 0.0
	load 11050200 $F4 0.0 0.0
	load 11040200 $F3 0.0 0.0
	load 11030200 $F2 0.0 0.0
	load 11020200 $F1 0.0 0.0
};


# Displacement Control Parameters
set CtrlNode 11070200;
set maxRoofDrift 0.1;  # $$$
set Dmax [expr $maxRoofDrift * $Floor7];
set Dincr [expr 0.5];
set result [PushoverAnalysis $CtrlNode $Dmax $Dincr $maxRunTime];
set status [lindex $result 0];
set roofDisp [lindex $result 1];
puts "Running status: $status";
puts "Roof displacement: $roofDisp";
puts "Roof drift ratio: [expr $roofDisp / $HBuilding]";
}

wipe all;


