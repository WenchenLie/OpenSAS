
wipe all;
model basic -ndm 2 -ndf 3;


# Basic model variables
set maxRunTime 600.0;  # $$$
set EQ 1;  # $$$
set PO 0;  # $$$
set ShowAnimation 1;  # $$$
set MPCO 0;  # $$$

# Ground motion information
set MainFolder "E:/MRF_results/test/4SMRF";  # $$$
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


set HBuilding 24300.0;
set story_heights [list 4300 4000 4000 4000 4000 4000];


# REDUCED BEAM SECTION CONNECTION DISTANCE FROM COLUMN
# These valuse are 0 actually, but the elstic beam column elements should have finite length.
set L_RBS7  [expr  20.0];
set L_RBS6  [expr  20.0];
set L_RBS5  [expr  20.0];
set L_RBS4  [expr  20.0];
set L_RBS3  [expr  20.0];
set L_RBS2  [expr  20.0];

# FRAME GRID LINES
set Floor7  24300.00;
set Floor6  20300.00;
set Floor5  16300.00;
set Floor4  12300.00;
set Floor3  8300.00;
set Floor2  4300.00;
set Floor1  0.0;

set Axis1 0.0;
set Axis2 6000.00;
set Axis3 9000.00;
set Axis4 15000.00;
set Axis5 21000.00;
set Axis6 27000.00;

set I_col1to3 [expr 1.0 / 12 * 600 * 600 ** 3];
set I_col4to6 [expr 1.0 / 12 * 550 * 550 ** 3];
set I_beam_E  [expr 1.0 / 12 * 250 * 550 ** 3];
set I_beam_I  [expr 1.0 / 12 * 250 * 400 ** 3];

set A_col1to3 [expr 600.0 * 600.0];
set A_col4to6 [expr 550.0 * 550.0];
set A_beam_E  [expr 250.0 * 550.0];
set A_beam_I  [expr 250.0 * 400.0];

# story mass
# set m1 128.02; set m2 126.94; set m3 126.94; set m4 124.64; set m5 124.64; set m6 102.0;  # with infilled wall
set m1 110.18; set m2 109.1; set m3 109.1; set m4 106.8; set m5 106.8; set m6 102.0;  # with infilled wall

# Axial compression ratio
set PPy_6I 0.11;  set PPy_6E 0.09;
set PPy_5I 0.23;  set PPy_5E 0.21;
set PPy_4I 0.36;  set PPy_4E 0.33;
set PPy_3I 0.40;  set PPy_3E 0.38;
set PPy_2I 0.51;  set PPy_2E 0.48;
set PPy_1I 0.62;  set PPy_1E 0.58;
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
# set EIEg_beam 1;  # TODO test for not considering stiffness reduction
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
	# set result 1.0;  # TODO test for not considering stiffness reduction
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
set sf 1.8
#                     fc  Ec  fy  Es  b   h  d1  s  rho_C    rho_T   rho_I  rho_SH  a_sl  PPc Units Length  EIyEIg  name
# floor 2
set IMKbeam_2E [list $fc $Ec $fy $Es 250 550 25 100 0.0141 	0.0054 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam ""  $sf];
set IMKbeam_2I [list $fc $Ec $fy $Es 250 550 25 100 0.0137 	0.0054 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam ""  $sf];
set IMKbeam_2M [list $fc $Ec $fy $Es 250 400 25 100 0.0159 	0.0137 	0.0000 	0.0040   1    0.0  1    2400  $EIEg_beam ""  $sf];
# floor 3
set IMKbeam_3E [list $fc $Ec $fy $Es 250 550 25 100 0.0142 	0.0053 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam ""  $sf];
set IMKbeam_3I [list $fc $Ec $fy $Es 250 550 25 100 0.0137 	0.0055 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam ""  $sf];
set IMKbeam_3M [list $fc $Ec $fy $Es 250 400 25 100 0.0159 	0.0137 	0.0000 	0.0040   1    0.0  1    2400  $EIEg_beam ""  $sf];
# floor 4
set IMKbeam_4E [list $fc $Ec $fy $Es 250 550 25 100 0.0136 	0.0048 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam ""  $sf];
set IMKbeam_4I [list $fc $Ec $fy $Es 250 550 25 100 0.0131 	0.0050 	0.0000 	0.0040   1    0.0  1    5400  $EIEg_beam ""  $sf];
set IMKbeam_4M [list $fc $Ec $fy $Es 250 400 25 100 0.0148 	0.0108 	0.0000 	0.0040   1    0.0  1    2400  $EIEg_beam ""  $sf];
# floor 5
set IMKbeam_5E [list $fc $Ec $fy $Es 250 550 25 100 0.0127 	0.0041 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam ""  $sf];
set IMKbeam_5I [list $fc $Ec $fy $Es 250 550 25 100 0.0109 	0.0042 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam ""  $sf];
set IMKbeam_5M [list $fc $Ec $fy $Es 250 400 25 100 0.0134 	0.0095 	0.0000 	0.0040   1    0.0  1    2450  $EIEg_beam ""  $sf];
# floor 6
set IMKbeam_6E [list $fc $Ec $fy $Es 250 550 25 100 0.0105 	0.0035 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam ""  $sf];
set IMKbeam_6I [list $fc $Ec $fy $Es 250 550 25 100 0.0101 	0.0034 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam ""  $sf];
set IMKbeam_6M [list $fc $Ec $fy $Es 250 400 25 100 0.0101 	0.0083 	0.0000 	0.0040   1    0.0  1    2450  $EIEg_beam ""  $sf];
# floor 7
set IMKbeam_7E [list $fc $Ec $fy $Es 250 550 25 100 0.0088 	0.0030 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam ""  $sf];
set IMKbeam_7I [list $fc $Ec $fy $Es 250 550 25 100 0.0082 	0.0030 	0.0000 	0.0040   1    0.0  1    5450  $EIEg_beam ""  $sf];
set IMKbeam_7M [list $fc $Ec $fy $Es 250 400 25 100 0.0087 	0.0067 	0.0000 	0.0040   1    0.0  1    2450  $EIEg_beam ""  $sf];

# column hinge parameters
#                     fc  Ec  fy  Es  b   h  d1  s  rho_C    rho_T   rho_I  rho_SH  a_sl  PPc Units Length  EIyEIg
# story 1
set IMKcol_1I  [list $fc $Ec $fy $Es 600 600 25 100 0.0031 	0.0031 	0.0031 	0.0033   1 $PPy_1I 1    3750 $EIEg_col_1I ""  $sf];
set IMKcol_1E  [list $fc $Ec $fy $Es 600 600 25 100 0.0033 	0.0033 	0.0033 	0.0033   1 $PPy_1E 1    3750 $EIEg_col_1E ""  $sf];
# story 2
set IMKcol_2I  [list $fc $Ec $fy $Es 600 600 25 100 0.0024 	0.0024 	0.0024 	0.0033   1 $PPy_2I 1    3450 $EIEg_col_2I ""  $sf];
set IMKcol_2E  [list $fc $Ec $fy $Es 600 600 25 100 0.0025 	0.0025 	0.0025 	0.0033   1 $PPy_2E 1    3450 $EIEg_col_2E ""  $sf];
# story 3
set IMKcol_3I  [list $fc $Ec $fy $Es 600 600 25 100 0.0024 	0.0024 	0.0024 	0.0033   1 $PPy_3I 1    3450 $EIEg_col_3I ""  $sf];
set IMKcol_3E  [list $fc $Ec $fy $Es 600 600 25 100 0.0041 	0.0041 	0.0041 	0.0033   1 $PPy_3E 1    3450 $EIEg_col_3E ""  $sf];
# story 4
set IMKcol_4I  [list $fc $Ec $fy $Es 550 550 25 100 0.0036 	0.0036 	0.0036 	0.0036   1 $PPy_4I 1    3450 $EIEg_col_4I ""  $sf];
set IMKcol_4E  [list $fc $Ec $fy $Es 550 550 25 100 0.0076 	0.0076 	0.0076 	0.0036   1 $PPy_4E 1    3450 $EIEg_col_4E ""  $sf];
# story 5
set IMKcol_5I  [list $fc $Ec $fy $Es 550 550 25 100 0.0036 	0.0036 	0.0036 	0.0036   1 $PPy_5I 1    3450 $EIEg_col_5I ""  $sf];
set IMKcol_5E  [list $fc $Ec $fy $Es 550 550 25 100 0.0066 	0.0066 	0.0066 	0.0036   1 $PPy_5E 1    3450 $EIEg_col_5E ""  $sf];
# story 6
set IMKcol_6I  [list $fc $Ec $fy $Es 550 550 25 100 0.0028 	0.0028 	0.0028 	0.0036   1 $PPy_6I 1    3450 $EIEg_col_6I ""  $sf];
set IMKcol_6E  [list $fc $Ec $fy $Es 550 550 25 100 0.0027 	0.0027 	0.0027 	0.0036   1 $PPy_6E 1    3450 $EIEg_col_6E ""  $sf];

####################################################################################################
#                                                  NODES                                           #
####################################################################################################

# COMMAND SYNTAX 
# node $NodeID  $X-Coordinate  $Y-Coordinate;

#SUPPORT NODES
node 110   $Axis1  $Floor1; node 120   $Axis2  $Floor1; node 130   $Axis3  $Floor1; node 140   $Axis4  $Floor1;

# MF COLUMN NODES
node 711  $Axis1 [expr $Floor7 - 550.0/2]; node 721  $Axis2 [expr $Floor7 - 550.0/2]; node 731  $Axis3 [expr $Floor7 - 550.0/2]; node 741  $Axis4 [expr $Floor7 - 550.0/2]; 
node 613  $Axis1 [expr $Floor6 + 550.0/2]; node 623  $Axis2 [expr $Floor6 + 550.0/2]; node 633  $Axis3 [expr $Floor6 + 550.0/2]; node 643  $Axis4 [expr $Floor6 + 550.0/2]; 
node 611  $Axis1 [expr $Floor6 - 550.0/2]; node 621  $Axis2 [expr $Floor6 - 550.0/2]; node 631  $Axis3 [expr $Floor6 - 550.0/2]; node 641  $Axis4 [expr $Floor6 - 550.0/2]; 
node 513  $Axis1 [expr $Floor5 + 550.0/2]; node 523  $Axis2 [expr $Floor5 + 550.0/2]; node 533  $Axis3 [expr $Floor5 + 550.0/2]; node 543  $Axis4 [expr $Floor5 + 550.0/2]; 
node 511  $Axis1 [expr $Floor5 - 550.0/2]; node 521  $Axis2 [expr $Floor5 - 550.0/2]; node 531  $Axis3 [expr $Floor5 - 550.0/2]; node 541  $Axis4 [expr $Floor5 - 550.0/2]; 
node 413  $Axis1 [expr $Floor4 + 550.0/2]; node 423  $Axis2 [expr $Floor4 + 550.0/2]; node 433  $Axis3 [expr $Floor4 + 550.0/2]; node 443  $Axis4 [expr $Floor4 + 550.0/2]; 
node 411  $Axis1 [expr $Floor4 - 550.0/2]; node 421  $Axis2 [expr $Floor4 - 550.0/2]; node 431  $Axis3 [expr $Floor4 - 550.0/2]; node 441  $Axis4 [expr $Floor4 - 550.0/2]; 
node 313  $Axis1 [expr $Floor3 + 550.0/2]; node 323  $Axis2 [expr $Floor3 + 550.0/2]; node 333  $Axis3 [expr $Floor3 + 550.0/2]; node 343  $Axis4 [expr $Floor3 + 550.0/2]; 
node 311  $Axis1 [expr $Floor3 - 550.0/2]; node 321  $Axis2 [expr $Floor3 - 550.0/2]; node 331  $Axis3 [expr $Floor3 - 550.0/2]; node 341  $Axis4 [expr $Floor3 - 550.0/2]; 
node 213  $Axis1 [expr $Floor2 + 550.0/2]; node 223  $Axis2 [expr $Floor2 + 550.0/2]; node 233  $Axis3 [expr $Floor2 + 550.0/2]; node 243  $Axis4 [expr $Floor2 + 550.0/2]; 
node 211  $Axis1 [expr $Floor2 - 550.0/2]; node 221  $Axis2 [expr $Floor2 - 550.0/2]; node 231  $Axis3 [expr $Floor2 - 550.0/2]; node 241  $Axis4 [expr $Floor2 - 550.0/2]; 
node 113  $Axis1 $Floor1; node 123  $Axis2 $Floor1; node 133  $Axis3 $Floor1; node 143  $Axis4 $Floor1; 

# MF BEAM NODES
node 714   [expr $Axis1 + $L_RBS7 + 550.0/2] $Floor7; node 722   [expr $Axis2 - $L_RBS7 - 550.0/2] $Floor7; node 724   [expr $Axis2 + $L_RBS7 + 550.0/2] $Floor7; node 732   [expr $Axis3 - $L_RBS7 - 550.0/2] $Floor7; node 734   [expr $Axis3 + $L_RBS7 + 550.0/2] $Floor7; node 742   [expr $Axis4 - $L_RBS7 - 550.0/2] $Floor7; 
node 614   [expr $Axis1 + $L_RBS6 + 550.0/2] $Floor6; node 622   [expr $Axis2 - $L_RBS6 - 550.0/2] $Floor6; node 624   [expr $Axis2 + $L_RBS6 + 550.0/2] $Floor6; node 632   [expr $Axis3 - $L_RBS6 - 550.0/2] $Floor6; node 634   [expr $Axis3 + $L_RBS6 + 550.0/2] $Floor6; node 642   [expr $Axis4 - $L_RBS6 - 550.0/2] $Floor6; 
node 514   [expr $Axis1 + $L_RBS5 + 550.0/2] $Floor5; node 522   [expr $Axis2 - $L_RBS5 - 550.0/2] $Floor5; node 524   [expr $Axis2 + $L_RBS5 + 550.0/2] $Floor5; node 532   [expr $Axis3 - $L_RBS5 - 550.0/2] $Floor5; node 534   [expr $Axis3 + $L_RBS5 + 550.0/2] $Floor5; node 542   [expr $Axis4 - $L_RBS5 - 550.0/2] $Floor5; 
node 414   [expr $Axis1 + $L_RBS4 + 600.0/2] $Floor4; node 422   [expr $Axis2 - $L_RBS4 - 600.0/2] $Floor4; node 424   [expr $Axis2 + $L_RBS4 + 600.0/2] $Floor4; node 432   [expr $Axis3 - $L_RBS4 - 600.0/2] $Floor4; node 434   [expr $Axis3 + $L_RBS4 + 600.0/2] $Floor4; node 442   [expr $Axis4 - $L_RBS4 - 600.0/2] $Floor4; 
node 314   [expr $Axis1 + $L_RBS3 + 600.0/2] $Floor3; node 322   [expr $Axis2 - $L_RBS3 - 600.0/2] $Floor3; node 324   [expr $Axis2 + $L_RBS3 + 600.0/2] $Floor3; node 332   [expr $Axis3 - $L_RBS3 - 600.0/2] $Floor3; node 334   [expr $Axis3 + $L_RBS3 + 600.0/2] $Floor3; node 342   [expr $Axis4 - $L_RBS3 - 600.0/2] $Floor3; 
node 214   [expr $Axis1 + $L_RBS2 + 600.0/2] $Floor2; node 222   [expr $Axis2 - $L_RBS2 - 600.0/2] $Floor2; node 224   [expr $Axis2 + $L_RBS2 + 600.0/2] $Floor2; node 232   [expr $Axis3 - $L_RBS2 - 600.0/2] $Floor2; node 234   [expr $Axis3 + $L_RBS2 + 600.0/2] $Floor2; node 242   [expr $Axis4 - $L_RBS2 - 600.0/2] $Floor2; 

# BEAM SPRING NODES
node 7140   [expr $Axis1 + $L_RBS7 + 550.0/2] $Floor7; node 7220   [expr $Axis2 - $L_RBS7 - 550.0/2] $Floor7; node 7240   [expr $Axis2 + $L_RBS7 + 550.0/2] $Floor7; node 7320   [expr $Axis3 - $L_RBS7 - 550.0/2] $Floor7; node 7340   [expr $Axis3 + $L_RBS7 + 550.0/2] $Floor7; node 7420   [expr $Axis4 - $L_RBS7 - 550.0/2] $Floor7; 
node 6140   [expr $Axis1 + $L_RBS6 + 550.0/2] $Floor6; node 6220   [expr $Axis2 - $L_RBS6 - 550.0/2] $Floor6; node 6240   [expr $Axis2 + $L_RBS6 + 550.0/2] $Floor6; node 6320   [expr $Axis3 - $L_RBS6 - 550.0/2] $Floor6; node 6340   [expr $Axis3 + $L_RBS6 + 550.0/2] $Floor6; node 6420   [expr $Axis4 - $L_RBS6 - 550.0/2] $Floor6; 
node 5140   [expr $Axis1 + $L_RBS5 + 550.0/2] $Floor5; node 5220   [expr $Axis2 - $L_RBS5 - 550.0/2] $Floor5; node 5240   [expr $Axis2 + $L_RBS5 + 550.0/2] $Floor5; node 5320   [expr $Axis3 - $L_RBS5 - 550.0/2] $Floor5; node 5340   [expr $Axis3 + $L_RBS5 + 550.0/2] $Floor5; node 5420   [expr $Axis4 - $L_RBS5 - 550.0/2] $Floor5; 
node 4140   [expr $Axis1 + $L_RBS4 + 600.0/2] $Floor4; node 4220   [expr $Axis2 - $L_RBS4 - 600.0/2] $Floor4; node 4240   [expr $Axis2 + $L_RBS4 + 600.0/2] $Floor4; node 4320   [expr $Axis3 - $L_RBS4 - 600.0/2] $Floor4; node 4340   [expr $Axis3 + $L_RBS4 + 600.0/2] $Floor4; node 4420   [expr $Axis4 - $L_RBS4 - 600.0/2] $Floor4; 
node 3140   [expr $Axis1 + $L_RBS3 + 600.0/2] $Floor3; node 3220   [expr $Axis2 - $L_RBS3 - 600.0/2] $Floor3; node 3240   [expr $Axis2 + $L_RBS3 + 600.0/2] $Floor3; node 3320   [expr $Axis3 - $L_RBS3 - 600.0/2] $Floor3; node 3340   [expr $Axis3 + $L_RBS3 + 600.0/2] $Floor3; node 3420   [expr $Axis4 - $L_RBS3 - 600.0/2] $Floor3; 
node 2140   [expr $Axis1 + $L_RBS2 + 600.0/2] $Floor2; node 2220   [expr $Axis2 - $L_RBS2 - 600.0/2] $Floor2; node 2240   [expr $Axis2 + $L_RBS2 + 600.0/2] $Floor2; node 2320   [expr $Axis3 - $L_RBS2 - 600.0/2] $Floor2; node 2340   [expr $Axis3 + $L_RBS2 + 600.0/2] $Floor2; node 2420   [expr $Axis4 - $L_RBS2 - 600.0/2] $Floor2; 

###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

# Command Syntax; 
# ConstructPanel_Cross Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag ShapeID
ConstructPanel_Cross  1  7 $Axis1 $Floor7 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected 23; ConstructPanel_Cross  2  7 $Axis2 $Floor7 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  3; ConstructPanel_Cross  3  7 $Axis3 $Floor7 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  3; ConstructPanel_Cross  4  7 $Axis4 $Floor7 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected 34; 
ConstructPanel_Cross  1  6 $Axis1 $Floor6 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  2; ConstructPanel_Cross  2  6 $Axis2 $Floor6 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  0; ConstructPanel_Cross  3  6 $Axis3 $Floor6 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  0; ConstructPanel_Cross  4  6 $Axis4 $Floor6 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  4; 
ConstructPanel_Cross  1  5 $Axis1 $Floor5 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  2; ConstructPanel_Cross  2  5 $Axis2 $Floor5 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  0; ConstructPanel_Cross  3  5 $Axis3 $Floor5 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  0; ConstructPanel_Cross  4  5 $Axis4 $Floor5 $Ec $A_Stiff $I_Stiff 550.0 550.0 $trans_selected  4; 
ConstructPanel_Cross  1  4 $Axis1 $Floor4 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  2; ConstructPanel_Cross  2  4 $Axis2 $Floor4 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  0; ConstructPanel_Cross  3  4 $Axis3 $Floor4 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  0; ConstructPanel_Cross  4  4 $Axis4 $Floor4 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  4; 
ConstructPanel_Cross  1  3 $Axis1 $Floor3 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  2; ConstructPanel_Cross  2  3 $Axis2 $Floor3 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  0; ConstructPanel_Cross  3  3 $Axis3 $Floor3 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  0; ConstructPanel_Cross  4  3 $Axis4 $Floor3 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  4; 
ConstructPanel_Cross  1  2 $Axis1 $Floor2 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  2; ConstructPanel_Cross  2  2 $Axis2 $Floor2 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  0; ConstructPanel_Cross  3  2 $Axis3 $Floor2 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  0; ConstructPanel_Cross  4  2 $Axis4 $Floor2 $Ec $A_Stiff $I_Stiff 600.0 550.0 $trans_selected  4; 

# COMMAND SYNTAX 
# element ModElasticBeam2d $ElementID $iNode $jNode $Area $E $Ix $K11 $K33 $K44 $transformation 

# STIFFNESS MODIFIERS
set n 10
set k_mod [expr ($n + 1.0) / $n];

# COLUMNS
element elasticBeamColumn  606100  613  711  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_6E*$I_col4to6] $trans_selected; element elasticBeamColumn   606200      623      721  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_6I*$I_col4to6] $trans_selected; element elasticBeamColumn   606300      633      731  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_6I*$I_col4to6] $trans_selected; element elasticBeamColumn   606400      643      741  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_6E*$I_col4to6] $trans_selected; 
element elasticBeamColumn  605100  513  611  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_5E*$I_col4to6] $trans_selected; element elasticBeamColumn   605200      523      621  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_5I*$I_col4to6] $trans_selected; element elasticBeamColumn   605300      533      631  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_5I*$I_col4to6] $trans_selected; element elasticBeamColumn   605400      543      641  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_5E*$I_col4to6] $trans_selected; 
element elasticBeamColumn  604100  413  511  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_4E*$I_col4to6] $trans_selected; element elasticBeamColumn   604200      423      521  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_4I*$I_col4to6] $trans_selected; element elasticBeamColumn   604300      433      531  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_4I*$I_col4to6] $trans_selected; element elasticBeamColumn   604400      443      541  $A_col4to6 $Ec [expr $k_mod*$EIEg_col_4E*$I_col4to6] $trans_selected; 
element elasticBeamColumn  603100  313  411  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_3E*$I_col1to3] $trans_selected; element elasticBeamColumn   603200      323      421  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_3I*$I_col1to3] $trans_selected; element elasticBeamColumn   603300      333      431  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_3I*$I_col1to3] $trans_selected; element elasticBeamColumn   603400      343      441  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_3E*$I_col1to3] $trans_selected; 
element elasticBeamColumn  602100  213  311  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_2E*$I_col1to3] $trans_selected; element elasticBeamColumn   602200      223      321  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_2I*$I_col1to3] $trans_selected; element elasticBeamColumn   602300      233      331  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_2I*$I_col1to3] $trans_selected; element elasticBeamColumn   602400      243      341  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_2E*$I_col1to3] $trans_selected; 
element elasticBeamColumn  601100  113  211  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_1E*$I_col1to3] $trans_selected; element elasticBeamColumn   601200      123      221  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_1I*$I_col1to3] $trans_selected; element elasticBeamColumn   601300      133      231  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_1I*$I_col1to3] $trans_selected; element elasticBeamColumn   601400      143      241  $A_col1to3 $Ec [expr $k_mod*$EIEg_col_1E*$I_col1to3] $trans_selected; 
# BEAMS
element elasticBeamColumn  507100  714  722  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; element elasticBeamColumn   507200      724      732  $A_beam_I $Ec [expr $k_mod*$EIEg_beam*$I_beam_I] $trans_selected; element elasticBeamColumn   507300      734      742  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; 
element elasticBeamColumn  506100  614  622  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; element elasticBeamColumn   506200      624      632  $A_beam_I $Ec [expr $k_mod*$EIEg_beam*$I_beam_I] $trans_selected; element elasticBeamColumn   506300      634      642  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; 
element elasticBeamColumn  505100  514  522  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; element elasticBeamColumn   505200      524      532  $A_beam_I $Ec [expr $k_mod*$EIEg_beam*$I_beam_I] $trans_selected; element elasticBeamColumn   505300      534      542  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; 
element elasticBeamColumn  504100  414  422  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; element elasticBeamColumn   504200      424      432  $A_beam_I $Ec [expr $k_mod*$EIEg_beam*$I_beam_I] $trans_selected; element elasticBeamColumn   504300      434      442  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; 
element elasticBeamColumn  503100  314  322  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; element elasticBeamColumn   503200      324      332  $A_beam_I $Ec [expr $k_mod*$EIEg_beam*$I_beam_I] $trans_selected; element elasticBeamColumn   503300      334      342  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; 
element elasticBeamColumn  502100  214  222  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; element elasticBeamColumn   502200      224      232  $A_beam_I $Ec [expr $k_mod*$EIEg_beam*$I_beam_I] $trans_selected; element elasticBeamColumn   502300      234      242  $A_beam_E $Ec [expr $k_mod*$EIEg_beam*$I_beam_E] $trans_selected; 

####################################################################################################
#                                      ELASTIC RBS ELEMENTS                                        #
####################################################################################################

element elasticBeamColumn 507104 407104 7140 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 507202 407202 7220 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 507204 407204 7240 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 507302 407302 7320 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 507304 407304 7340 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 507402 407402 7420 $A_beam_E $Ec $I_beam_E 1; 
element elasticBeamColumn 506104 406104 6140 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 506202 406202 6220 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 506204 406204 6240 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 506302 406302 6320 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 506304 406304 6340 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 506402 406402 6420 $A_beam_E $Ec $I_beam_E 1; 
element elasticBeamColumn 505104 405104 5140 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 505202 405202 5220 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 505204 405204 5240 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 505302 405302 5320 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 505304 405304 5340 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 505402 405402 5420 $A_beam_E $Ec $I_beam_E 1; 
element elasticBeamColumn 504104 404104 4140 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 504202 404202 4220 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 504204 404204 4240 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 504302 404302 4320 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 504304 404304 4340 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 504402 404402 4420 $A_beam_E $Ec $I_beam_E 1; 
element elasticBeamColumn 503104 403104 3140 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 503202 403202 3220 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 503204 403204 3240 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 503302 403302 3320 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 503304 403304 3340 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 503402 403402 3420 $A_beam_E $Ec $I_beam_E 1; 
element elasticBeamColumn 502104 402104 2140 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 502202 402202 2220 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 502204 402204 2240 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 502302 402302 2320 $A_beam_I $Ec $I_beam_I 1; element elasticBeamColumn 502304 402304 2340 $A_beam_E $Ec $I_beam_E 1; element elasticBeamColumn 502402 402402 2420 $A_beam_E $Ec $I_beam_E 1; 

###################################################################################################
#                                           MF BEAM SPRINGS                                       #
###################################################################################################

# Command Syntax 
# Spring_IMK SpringID iNode jNode E fy Ix d htw bftf ry L Ls Lb My PgPye CompositeFLAG MFconnection Units; 
ModSpring_IMK_RC 907104 714 7140 {*}$IMKbeam_7E; ModSpring_IMK_RC 907202 7220 722 {*}$IMKbeam_7I; ModSpring_IMK_RC 907204 724 7240 {*}$IMKbeam_7M; ModSpring_IMK_RC 907302 7320 732 {*}$IMKbeam_7M; ModSpring_IMK_RC 907304 734 7340 {*}$IMKbeam_7I; ModSpring_IMK_RC 907402 7420 742 {*}$IMKbeam_7E; 
ModSpring_IMK_RC 906104 614 6140 {*}$IMKbeam_6E; ModSpring_IMK_RC 906202 6220 622 {*}$IMKbeam_6I; ModSpring_IMK_RC 906204 624 6240 {*}$IMKbeam_6M; ModSpring_IMK_RC 906302 6320 632 {*}$IMKbeam_6M; ModSpring_IMK_RC 906304 634 6340 {*}$IMKbeam_6I; ModSpring_IMK_RC 906402 6420 642 {*}$IMKbeam_6E; 
ModSpring_IMK_RC 905104 514 5140 {*}$IMKbeam_5E; ModSpring_IMK_RC 905202 5220 522 {*}$IMKbeam_5I; ModSpring_IMK_RC 905204 524 5240 {*}$IMKbeam_5M; ModSpring_IMK_RC 905302 5320 532 {*}$IMKbeam_5M; ModSpring_IMK_RC 905304 534 5340 {*}$IMKbeam_5I; ModSpring_IMK_RC 905402 5420 542 {*}$IMKbeam_5E; 
ModSpring_IMK_RC 904104 414 4140 {*}$IMKbeam_4E; ModSpring_IMK_RC 904202 4220 422 {*}$IMKbeam_4I; ModSpring_IMK_RC 904204 424 4240 {*}$IMKbeam_4M; ModSpring_IMK_RC 904302 4320 432 {*}$IMKbeam_4M; ModSpring_IMK_RC 904304 434 4340 {*}$IMKbeam_4I; ModSpring_IMK_RC 904402 4420 442 {*}$IMKbeam_4E; 
ModSpring_IMK_RC 903104 314 3140 {*}$IMKbeam_3E; ModSpring_IMK_RC 903202 3220 322 {*}$IMKbeam_3I; ModSpring_IMK_RC 903204 324 3240 {*}$IMKbeam_3M; ModSpring_IMK_RC 903302 3320 332 {*}$IMKbeam_3M; ModSpring_IMK_RC 903304 334 3340 {*}$IMKbeam_3I; ModSpring_IMK_RC 903402 3420 342 {*}$IMKbeam_3E; 
ModSpring_IMK_RC 902104 214 2140 {*}$IMKbeam_2E; ModSpring_IMK_RC 902202 2220 222 {*}$IMKbeam_2I; ModSpring_IMK_RC 902204 224 2240 {*}$IMKbeam_2M; ModSpring_IMK_RC 902302 2320 232 {*}$IMKbeam_2M; ModSpring_IMK_RC 902304 234 2340 {*}$IMKbeam_2I; ModSpring_IMK_RC 902402 2420 242 {*}$IMKbeam_2E; 

###################################################################################################
#                                           MF COLUMN SPRINGS                                     #
###################################################################################################

ModSpring_IMK_RC  907101  407101     711 {*}$IMKcol_6E; ModSpring_IMK_RC  907201  407201     721 {*}$IMKcol_6I; ModSpring_IMK_RC  907301  407301     731 {*}$IMKcol_6I; ModSpring_IMK_RC  907401  407401     741 {*}$IMKcol_6E; 
ModSpring_IMK_RC  906103  406103     613 {*}$IMKcol_6E; ModSpring_IMK_RC  906203  406203     623 {*}$IMKcol_6I; ModSpring_IMK_RC  906303  406303     633 {*}$IMKcol_6I; ModSpring_IMK_RC  906403  406403     643 {*}$IMKcol_6E; 
ModSpring_IMK_RC  906101  406101     611 {*}$IMKcol_5E; ModSpring_IMK_RC  906201  406201     621 {*}$IMKcol_5I; ModSpring_IMK_RC  906301  406301     631 {*}$IMKcol_5I; ModSpring_IMK_RC  906401  406401     641 {*}$IMKcol_5E; 
ModSpring_IMK_RC  905103  405103     513 {*}$IMKcol_5E; ModSpring_IMK_RC  905203  405203     523 {*}$IMKcol_5I; ModSpring_IMK_RC  905303  405303     533 {*}$IMKcol_5I; ModSpring_IMK_RC  905403  405403     543 {*}$IMKcol_5E; 
ModSpring_IMK_RC  905101  405101     511 {*}$IMKcol_4E; ModSpring_IMK_RC  905201  405201     521 {*}$IMKcol_4I; ModSpring_IMK_RC  905301  405301     531 {*}$IMKcol_4I; ModSpring_IMK_RC  905401  405401     541 {*}$IMKcol_4E; 
ModSpring_IMK_RC  904103  404103     413 {*}$IMKcol_4E; ModSpring_IMK_RC  904203  404203     423 {*}$IMKcol_4I; ModSpring_IMK_RC  904303  404303     433 {*}$IMKcol_4I; ModSpring_IMK_RC  904403  404403     443 {*}$IMKcol_4E; 
ModSpring_IMK_RC  904101  404101     411 {*}$IMKcol_3E; ModSpring_IMK_RC  904201  404201     421 {*}$IMKcol_3I; ModSpring_IMK_RC  904301  404301     431 {*}$IMKcol_3I; ModSpring_IMK_RC  904401  404401     441 {*}$IMKcol_3E; 
ModSpring_IMK_RC  903103  403103     313 {*}$IMKcol_3E; ModSpring_IMK_RC  903203  403203     323 {*}$IMKcol_3I; ModSpring_IMK_RC  903303  403303     333 {*}$IMKcol_3I; ModSpring_IMK_RC  903403  403403     343 {*}$IMKcol_3E; 
ModSpring_IMK_RC  903101  403101     311 {*}$IMKcol_2E; ModSpring_IMK_RC  903201  403201     321 {*}$IMKcol_2I; ModSpring_IMK_RC  903301  403301     331 {*}$IMKcol_2I; ModSpring_IMK_RC  903401  403401     341 {*}$IMKcol_2E; 
ModSpring_IMK_RC  902103  402103     213 {*}$IMKcol_2E; ModSpring_IMK_RC  902203  402203     223 {*}$IMKcol_2I; ModSpring_IMK_RC  902303  402303     233 {*}$IMKcol_2I; ModSpring_IMK_RC  902403  402403     243 {*}$IMKcol_2E; 
ModSpring_IMK_RC  902101  402101     211 {*}$IMKcol_1E; ModSpring_IMK_RC  902201  402201     221 {*}$IMKcol_1I; ModSpring_IMK_RC  902301  402301     231 {*}$IMKcol_1I; ModSpring_IMK_RC  902401  402401     241 {*}$IMKcol_1E; 
ModSpring_IMK_RC  901103     110     113 {*}$IMKcol_1E; ModSpring_IMK_RC  901203     120     123 {*}$IMKcol_1I; ModSpring_IMK_RC  901303     130     133 {*}$IMKcol_1I; ModSpring_IMK_RC  901403     140     143 {*}$IMKcol_1E; 

###################################################################################################
#                                       BOUNDARY CONDITIONS                                       #
###################################################################################################

# MF SUPPORTS
fix 110 1 1 1; 
fix 120 1 1 1; 
fix 130 1 1 1; 
fix 140 1 1 1; 

# MF FLOOR MOVEMENT
equalDOF 407104 407204 1; equalDOF 407104 407304 1; equalDOF 407104 740 1; 
equalDOF 406104 406204 1; equalDOF 406104 406304 1; equalDOF 406104 640 1; 
equalDOF 405104 405204 1; equalDOF 405104 405304 1; equalDOF 405104 540 1; 
equalDOF 404104 404204 1; equalDOF 404104 404304 1; equalDOF 404104 440 1; 
equalDOF 403104 403204 1; equalDOF 403104 403304 1; equalDOF 403104 340 1; 
equalDOF 402104 402204 1; equalDOF 402104 402304 1; equalDOF 402104 240 1; 


# TIME
recorder Node -file $MainFolder/$SubFolder/Time.out  -time -node 110 -dof 1 disp;

# SUPPORT REACTIONS
recorder Node -file $MainFolder/$SubFolder/Support1.out -node     110 -dof 1 2 3 reaction; recorder Node -file $MainFolder/$SubFolder/Support2.out -node     120 -dof 1 2 3 reaction; recorder Node -file $MainFolder/$SubFolder/Support3.out -node     130 -dof 1 2 3 reaction; recorder Node -file $MainFolder/$SubFolder/Support4.out -node     140 -dof 1 2 3 reaction;

# FLOOR LATERAL DISPLACEMENT
recorder Node -file $MainFolder/$SubFolder/Disp7_MF.out  -node  407104 -dof 1 disp; 
recorder Node -file $MainFolder/$SubFolder/Disp6_MF.out  -node  406104 -dof 1 disp; 
recorder Node -file $MainFolder/$SubFolder/Disp5_MF.out  -node  405104 -dof 1 disp; 
recorder Node -file $MainFolder/$SubFolder/Disp4_MF.out  -node  404104 -dof 1 disp; 
recorder Node -file $MainFolder/$SubFolder/Disp3_MF.out  -node  403104 -dof 1 disp; 
recorder Node -file $MainFolder/$SubFolder/Disp2_MF.out  -node  402104 -dof 1 disp; 

# STORY DRIFT RATIO
recorder Drift -file $MainFolder/$SubFolder/SDR_Roof.out -iNode   110 -jNode  407104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR6_MF.out -iNode  406104 -jNode  407104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR5_MF.out -iNode  405104 -jNode  406104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR4_MF.out -iNode  404104 -jNode  405104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR3_MF.out -iNode  403104 -jNode  404104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR2_MF.out -iNode  402104 -jNode  403104 -dof 1 -perpDirn 2; 
recorder Drift -file $MainFolder/$SubFolder/SDR1_MF.out -iNode     110 -jNode  402104 -dof 1 -perpDirn 2; 

# FLOOR ACCELERATION
recorder Node -file $MainFolder/$SubFolder/RFA7_MF.out -node 407104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA6_MF.out -node 406104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA5_MF.out -node 405104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA4_MF.out -node 404104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA3_MF.out -node 403104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA2_MF.out -node 402104 -dof 1 accel; 
recorder Node -file $MainFolder/$SubFolder/RFA1_MF.out -node 110 -dof 1 accel; 

# FLOOR VELOCITY
recorder Node -file $MainFolder/$SubFolder/RFV7_MF.out -node  407104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV6_MF.out -node  406104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV5_MF.out -node  405104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV4_MF.out -node  404104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV3_MF.out -node  403104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV2_MF.out -node  402104 -dof 1 vel; 
recorder Node -file $MainFolder/$SubFolder/RFV1_MF.out -node     110 -dof 1 vel; 

# COLUMN ELASTIC ELEMENT FORCES
recorder Element -file $MainFolder/$SubFolder/Column61.out -ele  606100 force; recorder Element -file $MainFolder/$SubFolder/Column62.out -ele  606200 force; recorder Element -file $MainFolder/$SubFolder/Column63.out -ele  606300 force; recorder Element -file $MainFolder/$SubFolder/Column64.out -ele  606400 force;
recorder Element -file $MainFolder/$SubFolder/Column51.out -ele  605100 force; recorder Element -file $MainFolder/$SubFolder/Column52.out -ele  605200 force; recorder Element -file $MainFolder/$SubFolder/Column53.out -ele  605300 force; recorder Element -file $MainFolder/$SubFolder/Column54.out -ele  605400 force;
recorder Element -file $MainFolder/$SubFolder/Column41.out -ele  604100 force; recorder Element -file $MainFolder/$SubFolder/Column42.out -ele  604200 force; recorder Element -file $MainFolder/$SubFolder/Column43.out -ele  604300 force; recorder Element -file $MainFolder/$SubFolder/Column44.out -ele  604400 force;
recorder Element -file $MainFolder/$SubFolder/Column31.out -ele  603100 force; recorder Element -file $MainFolder/$SubFolder/Column32.out -ele  603200 force; recorder Element -file $MainFolder/$SubFolder/Column33.out -ele  603300 force; recorder Element -file $MainFolder/$SubFolder/Column34.out -ele  603400 force;
recorder Element -file $MainFolder/$SubFolder/Column21.out -ele  602100 force; recorder Element -file $MainFolder/$SubFolder/Column22.out -ele  602200 force; recorder Element -file $MainFolder/$SubFolder/Column23.out -ele  602300 force; recorder Element -file $MainFolder/$SubFolder/Column24.out -ele  602400 force;
recorder Element -file $MainFolder/$SubFolder/Column11.out -ele  601100 force; recorder Element -file $MainFolder/$SubFolder/Column12.out -ele  601200 force; recorder Element -file $MainFolder/$SubFolder/Column13.out -ele  601300 force; recorder Element -file $MainFolder/$SubFolder/Column14.out -ele  601400 force;

# COLUMN SPRINGS FORCES
recorder Element -file $MainFolder/$SubFolder/ColSpring71B_F.out -ele  907101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring72B_F.out -ele  907201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring73B_F.out -ele  907301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring74B_F.out -ele  907401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring61T_F.out -ele  906103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring62T_F.out -ele  906203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring63T_F.out -ele  906303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring64T_F.out -ele  906403 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring61B_F.out -ele  906101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring62B_F.out -ele  906201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring63B_F.out -ele  906301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring64B_F.out -ele  906401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring51T_F.out -ele  905103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring52T_F.out -ele  905203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring53T_F.out -ele  905303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring54T_F.out -ele  905403 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring51B_F.out -ele  905101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring52B_F.out -ele  905201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring53B_F.out -ele  905301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring54B_F.out -ele  905401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring41T_F.out -ele  904103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring42T_F.out -ele  904203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring43T_F.out -ele  904303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring44T_F.out -ele  904403 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_F.out -ele  904101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring42B_F.out -ele  904201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring43B_F.out -ele  904301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring44B_F.out -ele  904401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_F.out -ele  903103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring32T_F.out -ele  903203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring33T_F.out -ele  903303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring34T_F.out -ele  903403 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_F.out -ele  903101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring32B_F.out -ele  903201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring33B_F.out -ele  903301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring34B_F.out -ele  903401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_F.out -ele  902103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring22T_F.out -ele  902203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring23T_F.out -ele  902303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring24T_F.out -ele  902403 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_F.out -ele  902101 force; recorder Element -file $MainFolder/$SubFolder/ColSpring22B_F.out -ele  902201 force; recorder Element -file $MainFolder/$SubFolder/ColSpring23B_F.out -ele  902301 force; recorder Element -file $MainFolder/$SubFolder/ColSpring24B_F.out -ele  902401 force; 
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_F.out -ele  901103 force; recorder Element -file $MainFolder/$SubFolder/ColSpring12T_F.out -ele  901203 force; recorder Element -file $MainFolder/$SubFolder/ColSpring13T_F.out -ele  901303 force; recorder Element -file $MainFolder/$SubFolder/ColSpring14T_F.out -ele  901403 force; 

# COLUMN SPRINGS ROTATIONS
recorder Element -file $MainFolder/$SubFolder/ColSpring71B_D.out -ele  907101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring72B_D.out -ele  907201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring73B_D.out -ele  907301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring74B_D.out -ele  907401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring61T_D.out -ele  906103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring62T_D.out -ele  906203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring63T_D.out -ele  906303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring64T_D.out -ele  906403 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring61B_D.out -ele  906101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring62B_D.out -ele  906201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring63B_D.out -ele  906301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring64B_D.out -ele  906401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring51T_D.out -ele  905103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring52T_D.out -ele  905203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring53T_D.out -ele  905303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring54T_D.out -ele  905403 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring51B_D.out -ele  905101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring52B_D.out -ele  905201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring53B_D.out -ele  905301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring54B_D.out -ele  905401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring41T_D.out -ele  904103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring42T_D.out -ele  904203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring43T_D.out -ele  904303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring44T_D.out -ele  904403 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring41B_D.out -ele  904101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring42B_D.out -ele  904201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring43B_D.out -ele  904301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring44B_D.out -ele  904401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring31T_D.out -ele  903103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring32T_D.out -ele  903203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring33T_D.out -ele  903303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring34T_D.out -ele  903403 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring31B_D.out -ele  903101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring32B_D.out -ele  903201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring33B_D.out -ele  903301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring34B_D.out -ele  903401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring21T_D.out -ele  902103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring22T_D.out -ele  902203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring23T_D.out -ele  902303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring24T_D.out -ele  902403 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring21B_D.out -ele  902101 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring22B_D.out -ele  902201 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring23B_D.out -ele  902301 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring24B_D.out -ele  902401 deformation; 
recorder Element -file $MainFolder/$SubFolder/ColSpring11T_D.out -ele  901103 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring12T_D.out -ele  901203 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring13T_D.out -ele  901303 deformation; recorder Element -file $MainFolder/$SubFolder/ColSpring14T_D.out -ele  901403 deformation; 

# BEAM SPRINGS FORCES
recorder Element -file $MainFolder/$SubFolder/BeamSpring71R_F.out -ele   907104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring72L_F.out -ele   907202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring72R_F.out -ele   907204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring73L_F.out -ele   907302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring73R_F.out -ele   907304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring74L_F.out -ele   907402 force; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring61R_F.out -ele   906104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring62L_F.out -ele   906202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring62R_F.out -ele   906204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring63L_F.out -ele   906302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring63R_F.out -ele   906304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring64L_F.out -ele   906402 force; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring51R_F.out -ele   905104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring52L_F.out -ele   905202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring52R_F.out -ele   905204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring53L_F.out -ele   905302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring53R_F.out -ele   905304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring54L_F.out -ele   905402 force; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_F.out -ele   904104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_F.out -ele   904202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_F.out -ele   904204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_F.out -ele   904302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_F.out -ele   904304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_F.out -ele   904402 force; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_F.out -ele   903104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_F.out -ele   903202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_F.out -ele   903204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_F.out -ele   903302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_F.out -ele   903304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_F.out -ele   903402 force; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_F.out -ele   902104 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_F.out -ele   902202 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_F.out -ele   902204 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_F.out -ele   902302 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_F.out -ele   902304 force; recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_F.out -ele   902402 force; 

# BEAM SPRINGS ROTATIONS
recorder Element -file $MainFolder/$SubFolder/BeamSpring71R_D.out -ele   907104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring72L_D.out -ele   907202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring72R_D.out -ele   907204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring73L_D.out -ele   907302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring73R_D.out -ele   907304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring74L_D.out -ele   907402 deformation; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring61R_D.out -ele   906104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring62L_D.out -ele   906202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring62R_D.out -ele   906204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring63L_D.out -ele   906302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring63R_D.out -ele   906304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring64L_D.out -ele   906402 deformation; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring51R_D.out -ele   905104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring52L_D.out -ele   905202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring52R_D.out -ele   905204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring53L_D.out -ele   905302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring53R_D.out -ele   905304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring54L_D.out -ele   905402 deformation; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring41R_D.out -ele   904104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring42L_D.out -ele   904202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring42R_D.out -ele   904204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring43L_D.out -ele   904302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring43R_D.out -ele   904304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring44L_D.out -ele   904402 deformation; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring31R_D.out -ele   903104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring32L_D.out -ele   903202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring32R_D.out -ele   903204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring33L_D.out -ele   903302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring33R_D.out -ele   903304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring34L_D.out -ele   903402 deformation; 
recorder Element -file $MainFolder/$SubFolder/BeamSpring21R_D.out -ele   902104 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring22L_D.out -ele   902202 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring22R_D.out -ele   902204 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring23L_D.out -ele   902302 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring23R_D.out -ele   902304 deformation; recorder Element -file $MainFolder/$SubFolder/BeamSpring24L_D.out -ele   902402 deformation; 

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
mass 710 $m6_  1.e-9 1.e-9; mass 720 $m6_  1.e-9 1.e-9; mass 730 $m6_  1.e-9 1.e-9; mass 740 $m6_  1.e-9 1.e-9;
mass 610 $m5_  1.e-9 1.e-9; mass 620 $m5_  1.e-9 1.e-9; mass 630 $m5_  1.e-9 1.e-9; mass 640 $m5_  1.e-9 1.e-9;
mass 510 $m4_  1.e-9 1.e-9; mass 520 $m4_  1.e-9 1.e-9; mass 530 $m4_  1.e-9 1.e-9; mass 540 $m4_  1.e-9 1.e-9;
mass 410 $m3_  1.e-9 1.e-9; mass 420 $m3_  1.e-9 1.e-9; mass 430 $m3_  1.e-9 1.e-9; mass 440 $m3_  1.e-9 1.e-9;
mass 310 $m2_  1.e-9 1.e-9; mass 320 $m2_  1.e-9 1.e-9; mass 330 $m2_  1.e-9 1.e-9; mass 340 $m2_  1.e-9 1.e-9;
mass 210 $m1_  1.e-9 1.e-9; mass 220 $m1_  1.e-9 1.e-9; mass 230 $m1_  1.e-9 1.e-9; mass 240 $m1_  1.e-9 1.e-9;



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

    lappend mode [expr [nodeEigenvector 402104 $i 1]]
    lappend mode [expr [nodeEigenvector 403104 $i 1]]
    lappend mode [expr [nodeEigenvector 404104 $i 1]]
    lappend mode [expr [nodeEigenvector 405104 $i 1]]
    lappend mode [expr [nodeEigenvector 406104 $i 1]]
    lappend mode [expr [nodeEigenvector 407104 $i 1]]
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
	load 710 0. [expr -1.e4*$m6_*$scale] 0.; 	load 720 0. [expr -1.e4*$m6_*$scale] 0.; 	load 730 0. [expr -1.e4*$m6_*$scale] 0.; 	load 740 0. [expr -1.e4*$m6_*$scale] 0.; 
	load 610 0. [expr -1.e4*$m5_*$scale] 0.; 	load 620 0. [expr -1.e4*$m5_*$scale] 0.; 	load 630 0. [expr -1.e4*$m5_*$scale] 0.; 	load 640 0. [expr -1.e4*$m5_*$scale] 0.; 
	load 510 0. [expr -1.e4*$m4_*$scale] 0.; 	load 520 0. [expr -1.e4*$m4_*$scale] 0.; 	load 530 0. [expr -1.e4*$m4_*$scale] 0.; 	load 540 0. [expr -1.e4*$m4_*$scale] 0.; 
	load 410 0. [expr -1.e4*$m3_*$scale] 0.; 	load 420 0. [expr -1.e4*$m3_*$scale] 0.; 	load 430 0. [expr -1.e4*$m3_*$scale] 0.; 	load 440 0. [expr -1.e4*$m3_*$scale] 0.; 
	load 310 0. [expr -1.e4*$m2_*$scale] 0.; 	load 320 0. [expr -1.e4*$m2_*$scale] 0.; 	load 330 0. [expr -1.e4*$m2_*$scale] 0.; 	load 340 0. [expr -1.e4*$m2_*$scale] 0.; 
	load 210 0. [expr -1.e4*$m1_*$scale] 0.; 	load 220 0. [expr -1.e4*$m1_*$scale] 0.; 	load 230 0. [expr -1.e4*$m1_*$scale] 0.; 	load 240 0. [expr -1.e4*$m1_*$scale] 0.; 
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
set MF_FloorNodes  [list 402104 403104 404104 405104 406104 407104 ];

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
    set CollapseDrift 0.1;
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
	load 407104 $F6 0.0 0.0
	load 406104 $F5 0.0 0.0
	load 405104 $F4 0.0 0.0
	load 404104 $F3 0.0 0.0
	load 403104 $F2 0.0 0.0
	load 402104 $F1 0.0 0.0
};


# Displacement Control Parameters
set CtrlNode 407104;
set maxRoofDrift 0.1;  # $$$
set Dmax [expr $maxRoofDrift * $Floor5];
set Dincr [expr 0.5];
set result [PushoverAnalysis $CtrlNode $Dmax $Dincr $maxRunTime];
set status [lindex $result 0];
set roofDisp [lindex $result 1];
puts "Running status: $status";
puts "Roof displacement: $roofDisp";
puts "Roof drift ratio: [expr $roofDisp / $HBuilding]";
}

wipe all;


