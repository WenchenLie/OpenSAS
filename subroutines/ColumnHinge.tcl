# -------------------------- Construct beam hinge model --------------------------
#
# Args (14):
# ---------------
# SpringID       Zero length element ID
# NodeI          Node i ID
# NodeJ          Node j ID
# E              Young's modulus
# Ix             Moment of inertia of section
# d              Section depth
# htw            Web slenderness ratio
# ry             Radius of gyration
# L              Member Length
# Lb             Unbraced length
# My             Effective Yield Moment
# PPy            Axial load ratio due to gravity
# SF_PPy         Scale factor of axial load ratio (due to overturning effect)
# pinned         Column base pinned connection (1: fixed, 2: pinned)
# check          Print IMK model parameters
# 
# ---------------
# Reference:
# [1] Proposed Updates to the ASCE 41 Nonlinear Modeling Parameters for Wide-Flange Steel Columns in Support of Performance-Based Seismic Engineering
# ---------------
# Written by: Wenchen Lie, Guangzhou University, China
# Date: 2024-03-14
# --------------------------------------------------------------------------------


proc ColumnHinge {SpringID NodeI NodeJ E Ix d htw ry L Lb My PPy SF_PPy pinned {check ""}} {

    set n 10.0;
    set c1 1.0;
    set c2 1.0;
    set PPy [expr $PPy * double($SF_PPy)];  # Enlarge PPy for considering overturning effect

    set K [expr ($n+1.0) * 6 * $E * $Ix / $L];

    set theta_p [expr 294.0 * pow(($htw),-1.700) * pow(($Lb/$ry),-0.700) * pow((1-$PPy),1.600)];  # Eq. (7), [1]
    set theta_pc [expr 90.0 * pow(($htw),-0.800) * pow(($Lb/$ry),-0.800) * pow((1-$PPy),2.500)];  # Eq. (9), [1]
    if {$theta_p > 0.20} {set theta_p 0.2}
    if {$theta_pc > 0.30} {set theta_pc 0.3}

    if {$PPy <= 0.35} {
        set Lamda [expr 25500. * pow(($htw),-2.140) * pow(($Lb/$ry),-0.530) * pow((1-$PPy),4.920)];
    } else {
        set Lamda [expr 268000. * pow(($htw),-2.300) * pow(($Lb/$ry),-1.300) * pow((1-$PPy),1.190)];	
    }
    if {$Lamda < 3.0} {set Lamda 3.0}

    if {$PPy < 0.2} {
        set My [expr (1.15/1.1)*$My*(1-$PPy/2)];
    } else {
        set My [expr (1.15/1.1)*$My*(9/8)*(1-$PPy)];
    };  # Eq. (2), [1]

    set McMy [expr 12.5 * pow(($htw),-0.200) * pow(($Lb/$ry),-0.400) * pow((1-$PPy),0.400)];  # Eq. (3), [1]
    if {$McMy < 1.0} {set McMy 1.0}
    if {$McMy > 1.3} {set McMy 1.3}

    # set theta_y [expr $My/(6 * $E * $Ix / $L)];
    # set theta_p [expr $theta_p - ($McMy-1.0)*$My/(6 * $E * $Ix / $L)];
    # set theta_pc [expr $theta_pc + $theta_y + ($McMy-1.0)*$My/(6 * $E * $Ix / $L)];

    set theta_u 0.15;
    set D 1.0;
    set Res [expr 0.5-0.4*$PPy];  # E1. (5), [1]
    set c 1.0;

    uniaxialMaterial IMKBilin $SpringID $K $theta_p $theta_pc $theta_u $My $McMy $Res $theta_p $theta_pc $theta_u $My $McMy $Res $Lamda [expr 0.9*$Lamda] [expr 0.9*$Lamda] $c $c $c $D $D;
    if {$pinned == 1} {
        element zeroLength $SpringID $NodeI $NodeJ -mat 99 99 $SpringID -dir 1 2 6;
    } elseif {$pinned == 2} {
        element zeroLength $SpringID $NodeI $NodeJ -mat 99 99 9 -dir 1 2 6;
    }
    if {$check ne ""} {
        puts "$check:\nKs: $K, My: $My, theta_p: $theta_p, theta_pc: $theta_pc, Res: $Res"
    }
}



