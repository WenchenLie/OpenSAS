# ---------------------------------- add 4-story rocking frame ----------------------------------------
# the link is pin-connected to the rocking frame and the moment frame
# -----------------------------------------------------------------------------------------------------

set BayLeft 6100;  # Rocking frame span
set BayRight 6100;  # Link span
set LinkLength 5000;  # Link length

# column property (gravity column, W14x90)
set A_col 17096.74;
set I_col 415815194.174;
# beam property (gravity baem, W24x55)
set A_beam 10451.592
set I_beam 561912424.56
# truss property (HSS12x8x5/16)
set A_truss1 18193.512;  # story 1
set A_truss 7161;  # story 2-4


set Axis99 [expr -$BayLeft - $BayRight]
set Axis98 [expr -$BayRight]
set offset [expr double($BayRight - $LinkLength) / 2];  # distance from axis line to the spring

# --- Node ---
# Axis 99
node 1990 $Axis99 0; node 1993 $Axis99 0;  # base
node 2990 $Axis99 $Floor2;  # floor 2
node 3990 $Axis99 $Floor3;  # floor 3
# node 1039971 $Axis99 [expr $Floor3 + 0.5 * ($Floor4 - $Floor3)]; node 1039972 $Axis99 [expr $Floor3 + 0.5 * ($Floor4 - $Floor3)];  # column splices at story 3
node 4990 $Axis99 $Floor4;  # floor 4
node 5990 $Axis99 $Floor5;  # floor 5
# Axis 98
node 2980 $Axis98 $Floor2;  # floor 2
node 3980 $Axis98 $Floor3;  # floor 3
# node 1039871 $Axis98 [expr $Floor3 + 0.5 * ($Floor4 - $Floor3)]; node 1039872 $Axis98 [expr $Floor3 + 0.5 * ($Floor4 - $Floor3)];  # column splices at story 3
node 4980 $Axis98 $Floor4;  # floor 4
node 5980 $Axis98 $Floor5;  # floor 5
# Link hinge nodes
node 29840 [expr $Axis98 + $offset] $Floor2; node 2984 [expr $Axis98 + $offset] $Floor2; node 212 [expr $Axis1 - $offset] $Floor2; node 2120 [expr $Axis1 - $offset] $Floor2;  # floor 2
node 39840 [expr $Axis98 + $offset] $Floor3; node 3984 [expr $Axis98 + $offset] $Floor3; node 312 [expr $Axis1 - $offset] $Floor3; node 3120 [expr $Axis1 - $offset] $Floor3;  # floor 3
node 49840 [expr $Axis98 + $offset] $Floor4; node 4984 [expr $Axis98 + $offset] $Floor4; node 412 [expr $Axis1 - $offset] $Floor4; node 4120 [expr $Axis1 - $offset] $Floor4;  # floor 4
node 59840 [expr $Axis98 + $offset] $Floor5; node 5984 [expr $Axis98 + $offset] $Floor5; node 512 [expr $Axis1 - $offset] $Floor5; node 5120 [expr $Axis1 - $offset] $Floor5;  # floor 5

# --- Element ---
# column
element elasticBeamColumn 6019900 1993 2990 $A_col $E $I_col $trans_selected;  # story 1
element elasticBeamColumn 6029900 2990 3990 $A_col $E $I_col $trans_selected; element elasticBeamColumn 6029800 2980 3980 $A_col $E $I_col $trans_selected;  # story 2
element elasticBeamColumn 6039900 3990 4990 $A_col $E $I_col $trans_selected; element elasticBeamColumn 6039800 3980 4980 $A_col $E $I_col $trans_selected;  # story 3
element elasticBeamColumn 6049900 4990 5990 $A_col $E $I_col $trans_selected; element elasticBeamColumn 6049800 4980 5980 $A_col $E $I_col $trans_selected;  # story 4
# beam
element elasticBeamColumn 5029900 2990 2980 $A_beam $E $I_beam $trans_selected; element elasticBeamColumn 5002984 2980 29840 $A_beam $E $I_beam $trans_selected; element elasticBeamColumn 5029800 2984 212 13870.9400 $E 665970280.9600 $trans_selected; element elasticBeamColumn 500212 2120 402102 13870.9400 $E 665970280.9600 $trans_selected;  # floor 2
element elasticBeamColumn 5039900 3990 3980 $A_beam $E $I_beam $trans_selected; element elasticBeamColumn 5003984 3980 39840 $A_beam $E $I_beam $trans_selected; element elasticBeamColumn 5039800 3984 312 13870.9400 $E 665970280.9600 $trans_selected; element elasticBeamColumn 500312 3120 403102 13870.9400 $E 665970280.9600 $trans_selected;  # floor 3
element elasticBeamColumn 5049900 4990 4980 $A_beam $E $I_beam $trans_selected; element elasticBeamColumn 5004984 4980 49840 $A_beam $E $I_beam $trans_selected; element elasticBeamColumn 5049800 4984 412 10774.1720 $E 486990767.9520 $trans_selected; element elasticBeamColumn 500412 4120 404102 10774.1720 $E 486990767.9520 $trans_selected;  # floor 4
element elasticBeamColumn 5059900 5990 5980 $A_beam $E $I_beam $trans_selected; element elasticBeamColumn 5005984 5980 59840 $A_beam $E $I_beam $trans_selected; element elasticBeamColumn 5059800 5984 512 10774.1720 $E 486990767.9520 $trans_selected; element elasticBeamColumn 500512 5120 405102 10774.1720 $E 486990767.9520 $trans_selected;  # floor 5
# Truss
element truss 741991 1993 2980 $A_truss1 666;  # story 1
element truss 742991 2990 3980 $A_truss 666; element truss 742992 2980 3990 $A_truss 666;  # story 2
element truss 743991 3990 4980 $A_truss 666; element truss 743992 3980 4990 $A_truss 666;  # story 3
element truss 744991 4990 5980 $A_truss 666; element truss 744992 4980 5990 $A_truss 666;  # story 3

# --- Zero length link ---
# column base
Spring_Zero 9001993 1990 1993;
# Link beam hinge
Spring_Zero 9002984 29840 2984; Spring_Zero 900212 212 2120;  # floor 2
Spring_Zero 9003984 39840 3984; Spring_Zero 900312 312 3120;  # floor 3
Spring_Zero 9004984 49840 4984; Spring_Zero 900412 412 4120;  # floor 4
Spring_Zero 9005984 59840 5984; Spring_Zero 900512 512 5120;  # floor 5

# --- Constrain ---
fix 1990 1 1 1;

# --- Recorder ---
# Column forces (story: 1-4, axis: 1-4)          Asix 99
recorder Element -file $MainFolder/$SubFolder/R_Column11.out -ele 6019900 force;  # Story 1                                      Asix 98
recorder Element -file $MainFolder/$SubFolder/R_Column21.out -ele 6029900 force; recorder Element -file $MainFolder/$SubFolder/R_Column22.out -ele 6029800 force;  # Story 2
recorder Element -file $MainFolder/$SubFolder/R_Column31.out -ele 6039900 force; recorder Element -file $MainFolder/$SubFolder/R_Column32.out -ele 6039800 force;  # Story 3
recorder Element -file $MainFolder/$SubFolder/R_Column41.out -ele 6049900 force; recorder Element -file $MainFolder/$SubFolder/R_Column42.out -ele 6049800 force;  # Story 4

# Beams for left bay (floor: 2-5, span: 1-2)     Asix 99
recorder Element -file $MainFolder/$SubFolder/R_Beam21.out -ele 5029900 force;  # Story 1
recorder Element -file $MainFolder/$SubFolder/R_Beam31.out -ele 5039900 force;  # Story 2
recorder Element -file $MainFolder/$SubFolder/R_Beam41.out -ele 5049900 force;  # Story 3
recorder Element -file $MainFolder/$SubFolder/R_Beam51.out -ele 5059900 force;  # Story 4

# Links for right bay (floor: 2-5, span: 1-2)
recorder Element -file $MainFolder/$SubFolder/R_Link21.out -ele 5029800 force;  # Story 1
recorder Element -file $MainFolder/$SubFolder/R_Link31.out -ele 5039800 force;  # Story 2
recorder Element -file $MainFolder/$SubFolder/R_Link41.out -ele 5049800 force;  # Story 3
recorder Element -file $MainFolder/$SubFolder/R_Link51.out -ele 5059800 force;  # Story 4

# Truss elements (story: 1-4, span: 1-2, form: a(/) b(\))
recorder Element -file $MainFolder/$SubFolder/R_Truss11a.out -ele 741991 axialForce;  # Story 1
recorder Element -file $MainFolder/$SubFolder/R_Truss21a.out -ele 742991 axialForce; recorder Element -file $MainFolder/$SubFolder/R_Truss21b.out -ele 742992 axialForce;  # Story 2
recorder Element -file $MainFolder/$SubFolder/R_Truss31a.out -ele 743991 axialForce; recorder Element -file $MainFolder/$SubFolder/R_Truss31b.out -ele 743992 axialForce;  # Story 3
recorder Element -file $MainFolder/$SubFolder/R_Truss41a.out -ele 744991 axialForce; recorder Element -file $MainFolder/$SubFolder/R_Truss41b.out -ele 744992 axialForce;  # Story 4

# Support (axis: 1-2)
recorder Node -file $MainFolder/$SubFolder/R_Support1.out -node 1990 -dof 1 2 6 reaction;

