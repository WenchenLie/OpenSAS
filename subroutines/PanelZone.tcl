# -------------------------- Construct panel zone model --------------------------
#
# Args (16):
# ---------------
# Floor          FLoor number
# Axis           Axis number
# X, Y           Coordiate of panel zone center
# E              Young's modulus
# mu             Possion ration
# fy             Yield strength
# A_stiff        Cross section area of rigid link
# I_stiff        Moment of inertia of rigid link
# d_col          Column section depth
# d_beam         Beam section depth
# tp             Panel zone thickness (column web + doubler plate)
# tf             Column flange thickness
# bf             Column flange width
# transfTag      Geometric transformation ID
# type_          Modeling approach (1: Parallelogram, 2: Cruciform)
# position       Panel zone position
#                   I: Internal
#                   L: Left
#                   R: Right
#                   T: top
#                   LT: Left top
#                   RT: Right top
# check          Print Hysteretic model parameters
# 
# ---------------
# Written by: Wenchen Lie, Guangzhou University, China
# Date: 2024-03-13
# --------------------------------------------------------------------------------


proc PanelZone {Floor Axis X Y E mu fy A_stiff I_stiff d_col d_beam tp tf bf transfTag type_ position {check ""}} {

    # node ID
    set node_C [expr 11000000 + $Floor*10000 + $Axis*100];  # 11FFAA01
    set node_B [expr $node_C + 1];  # 11FFAA01
    set node_L [expr $node_C + 2];  # 11FFAA02
    set node_T [expr $node_C + 3];  # 11FFAA03
    set node_R [expr $node_C + 4];  # 11FFAA04
    set node_BL [expr $node_C + 5];  # 11FFAA05
    set node_LB [expr $node_C + 6];  # 11FFAA06
    set node_LT [expr $node_C + 7];  # 11FFAA07
    set node_TL [expr $node_C + 8];  # 11FFAA08
    set node_TR [expr $node_C + 9];  # 11FFAA09
    set node_RT [expr $node_C + 10];  # 11FFAA10
    set node_RB [expr $node_C + 11];  # 11FFAA11
    set node_BR [expr $node_C + 12];  # 11FFAA12

    # Construct nodes
    if {$type_ == 1} {
        node $node_B $X [expr $Y-0.5*$d_beam];
        node $node_R [expr $X+0.5*$d_col] $Y;
        node $node_T $X [expr $Y+0.5*$d_beam];
        node $node_L [expr $X-0.5*$d_col] $Y;
    } elseif {$type_ == 2} {
        node $node_B $X [expr $Y-0.5*$d_beam];
        node $node_R [expr $X+0.5*$d_col] $Y;
        if {$position != "L" && $position != "LT"} {
            node $node_L [expr $X-0.5*$d_col] $Y;
        }
        if {$position != "T" && $position != "LT" && $position != "RT"} {
            node $node_T $X [expr $Y+0.5*$d_beam];
        }
    }
    if {$type_ == 1} {
        node $node_BL [expr $X-0.5*$d_col] [expr $Y-0.5*$d_beam];
        node $node_LB [expr $X-0.5*$d_col] [expr $Y-0.5*$d_beam];
        node $node_LT [expr $X-0.5*$d_col] [expr $Y+0.5*$d_beam];
        node $node_TL [expr $X-0.5*$d_col] [expr $Y+0.5*$d_beam];
        node $node_TR [expr $X+0.5*$d_col] [expr $Y+0.5*$d_beam];
        node $node_RT [expr $X+0.5*$d_col] [expr $Y+0.5*$d_beam];
        node $node_RB [expr $X+0.5*$d_col] [expr $Y-0.5*$d_beam];
        node $node_BR [expr $X+0.5*$d_col] [expr $Y-0.5*$d_beam];
    } elseif {$type_ == 2} {
        node $node_C $X $Y
    }

    # Rigid elements ID
    set ele_B [expr 11000000+$Floor*10000+$Axis*100+1];
    set ele_L [expr $ele_B + 1];
    set ele_T [expr $ele_B + 2];
    set ele_R [expr $ele_B + 3];
    set ele_BL [expr 11000000+$Floor*10000+$Axis*100+1];
    set ele_LB [expr $ele_BL + 1];
    set ele_LT [expr $ele_BL + 2];
    set ele_TL [expr $ele_BL + 3];
    set ele_TR [expr $ele_BL + 4];
    set ele_RT [expr $ele_BL + 5];
    set ele_RB [expr $ele_BL + 6];
    set ele_BR [expr $ele_BL + 7];

    # Construct rigid elements
    if {$type_ == 1} {
        element elasticBeamColumn $ele_BL $node_B $node_BL $A_stiff $E $I_stiff $transfTag;
        element elasticBeamColumn $ele_LB $node_LB $node_L $A_stiff $E $I_stiff $transfTag;
        element elasticBeamColumn $ele_LT $node_L $node_LT $A_stiff $E $I_stiff $transfTag;
        element elasticBeamColumn $ele_TL $node_TL $node_T $A_stiff $E $I_stiff $transfTag;
        element elasticBeamColumn $ele_TR $node_T $node_TR $A_stiff $E $I_stiff $transfTag;
        element elasticBeamColumn $ele_RT $node_RT $node_R $A_stiff $E $I_stiff $transfTag;
        element elasticBeamColumn $ele_RB $node_R $node_RB $A_stiff $E $I_stiff $transfTag;
        element elasticBeamColumn $ele_BR $node_BR $node_B $A_stiff $E $I_stiff $transfTag;
    } elseif {$type_ == 2} {
        element elasticBeamColumn $ele_B $node_C $node_B $A_stiff $E $I_stiff $transfTag;
        element elasticBeamColumn $ele_R $node_C $node_R $A_stiff $E $I_stiff $transfTag;
        if {$position != "L" && $position != "LT"} {
            element elasticBeamColumn $ele_L $node_C $node_L $A_stiff $E $I_stiff $transfTag;
        }
        if {$position != "T" && $position != "LT" && $position != "RT"} {
            element elasticBeamColumn $ele_T $node_C $node_T $A_stiff $E $I_stiff $transfTag;
        }
    }

    # Restrain DOF at panel coners
    if {$type_ == 1} {
        equalDOF $node_RB $node_BR 1 2;
        equalDOF $node_BL $node_LB 1 2;
        equalDOF $node_LT $node_TL 1 2;
        equalDOF $node_TR $node_RT 1 2;
    }

    # Calculating shear behavior
    set G [expr $E / (2 * (1 + $mu))];  # shear modulus
    # 1
    set V1 [expr 0.55 * $fy * $d_col * $tp];  # yield force
    set M1 [expr $V1 * $d_beam];  # yield moment
    set gamma1 [expr $fy / ($G * pow(3, 0.5))];  # yield rotation
    set K1 [expr 0.95 * $d_col * $tp * $G];  # elastic stiffness
    set Kgamma1 [expr $M1 / $gamma1];  # elastic rotational stiffness
    # 2
    set gamma2 [expr 4.0 * $gamma1];
    set V2 [expr 0.55 * $fy * $d_col * $tp * (1 + (3.0*$bf*$tf**2) / ($d_beam*$d_col*$tp))];
    set M2 [expr $V2 * $d_beam];
    # 3
    set Kgamma3 [expr 0.03 * $Kgamma1];
    set gamma3 [expr 100. * $gamma1];
    set M3 [expr $M2 + ($gamma3 - $gamma2) * $Kgamma3];
    # Ultimate
    set gammaU 0.3;

    # Construct panel zone spring
    if {$type_ == 1} {
        set spring_id [expr 11000000+$Floor*10000+$Axis*100];
        uniaxialMaterial Hysteretic [expr $spring_id+1]  $M1 $gamma1 $M2 $gamma2 $M3 $gamma3 [expr -$M1] [expr -$gamma1] [expr -$M2] [expr -$gamma2] [expr -$M3] [expr -$gamma3] 0.25 0.75 0. 0. 0.;
        uniaxialMaterial MinMax $spring_id [expr $spring_id+1] -min [expr -$gammaU] -max $gammaU;
        element zeroLength $spring_id $node_TR $node_RT -mat $spring_id -dir 6;
    }

    if {$check ne ""} {
        puts $check
        puts "M1: $M1, M2: $M2, M3: $M3"
        puts "gamma1: $gamma1, gamma2: $gamma2, gamma3: $gamma3"
    }
}


if {[file tail [info script]] eq [file tail $argv0]} {
    puts "This script is running as the main program"
}
