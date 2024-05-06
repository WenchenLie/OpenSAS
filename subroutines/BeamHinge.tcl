# -------------------------- Construct beam hinge model --------------------------
#
# Args (17):
# ---------------
# SpringID       Zero length element ID
# NodeI          Node i ID
# NodeJ          Node j ID
# E              Young's modulus
# fy             Yield strength
# Ix             Moment of inertia of section
# d              Section depth
# htw            Web slenderness ratio
# bftf           Flange slenderness ratio
# ry             Radius of gyration
# L              Member Length
# Ls             Shear Span
# Lb             Unbraced length
# My             Effective Yield Moment
# type_          Type of beam-to-column connection
#                   1: Reduced beam section (RBS)
#                   2: Other than RBS
#                   3: Pinned
#                   4: Elastic
# check          If given, print IMK model parameters
# 
# ---------------
# Reference:
# [1] Deterioration Modeling of Steel Components in Support of Collapse Prediction of Steel Moment Frames under Earthquake Loading
# ---------------
# Written by: Wenchen Lie, Guangzhou University, China
# Date: 2024-03-14
# --------------------------------------------------------------------------------


proc BeamHinge {SpringID NodeI NodeJ E fy Ix d htw bftf ry L Ls Lb My type_ {check ""}} {

    set n 10.0;
    set c1 1.0;
    set c2 1.0;

    set K [expr ($n+1.0) * 6 * $E * $Ix / $L];

    set McMy 1.1;
    if {$type_ == 1} {
        # RBS hinge
        set theta_p [expr 0.19 * pow(($htw), -0.314) * pow(($bftf), -0.100) * pow(($Lb/$ry), -0.185) * pow(($Ls/$d), 0.113) * pow(($c1 * $d/533), -0.760) * pow(($c2 * $fy / 355), -0.070)];  # Eq. (9), [1]
        set theta_pc [expr 9.52 * pow(($htw), -0.513) * pow(($bftf), -0.863) * pow(($Lb/$ry), -0.108) * pow(($c2 * $fy / 355), -0.360)];  # Eq. (12), [1]
        set Lamda [expr 585  * pow(($htw), -1.140) * pow(($bftf), -0.632) * pow(($Lb/$ry), -0.205) * pow(($c2 * $fy / 355), -0.391)];  # Eq. (15), [1]
    } elseif {$type_ == 2} {
        # Other than RBS section
        if {$d >= 533.0} {
            set theta_p [expr 0.318 * pow(($htw),-0.550) * pow(($bftf),-0.345) * pow(($Lb/$ry),-0.023) * pow(($Ls/$d),0.090) * pow(($c1 * $d/533),-0.330) * pow(($c2 * $fy / 355),-0.130)];  # Eq. (8), [1]
            set theta_pc [expr 7.500 * pow(($htw),-0.610) * pow(($bftf),-0.710) * pow(($Lb/$ry),-0.110) * pow(($c1 * $d/533),-0.161) * pow(($c2 * $fy / 355),-0.320)];  # Eq. (11), [1]
            set Lamda [expr 536 * pow(($htw),-1.260) * pow(($bftf),-0.525) * pow(($Lb/$ry),-0.130) * pow(($c2 * $fy / 355),-0.291)];  # Eq. (14), [1]
        } else {
            set theta_p [expr 0.0865 * pow(($htw),-0.360) * pow(($bftf),-0.140) * pow(($Ls/$d),0.340) * pow(($c1 * $d/533),-0.721) * pow(($c2 * $fy /355),-0.230)];  # Eq. (7), [1]
            set theta_pc [expr 5.6300 * pow(($htw),-0.565) * pow(($bftf),-0.800) * pow(($c1 * $d/533),-0.280) * pow(($c2 * $fy /355),-0.430)];  # Eq. (10), [1]
            set Lamda [expr 495 * pow(($htw),-1.340) * pow(($bftf),-0.595) * pow(($c2 * $fy /355),-0.360)];  # Eq. (13), [1]
        }
    }


    if {$type_ == 3} {
        # Beam column hinged connection
        element zeroLength $SpringID $NodeI $NodeJ -mat 99 99 9 -dir 1 2 6;
        # element zeroLength $SpringID $NodeI $NodeJ -mat 9 -dir 6;
        # equalDOF $NodeI $NodeJ 1 2;
    } elseif {$type_ == 4} {
        # Elastic beam hinge
        uniaxialMaterial Elastic $SpringID $K;
        element zeroLength $SpringID $NodeI $NodeJ -mat 99 99 $SpringID -dir 1 2 6;
    } else {
        # TODO Corrected rotations to account for elastic deformations
        # set theta_y [expr $My/(6 * $E * $Ix / $L)];
        # set theta_p [expr $theta_p - ($McMy-1.0)*$My/(6 * $E * $Ix / $L)];
        # set theta_pc [expr $theta_pc + $theta_y + ($McMy-1.0)*$My/(6 * $E * $Ix / $L)];
        set theta_u 0.2;
        set D 1.0;
        set Res 0.4;
        set c 1.0;
        uniaxialMaterial IMKBilin $SpringID $K $theta_p $theta_pc $theta_u $My $McMy $Res $theta_p $theta_pc $theta_u $My $McMy $Res $Lamda $Lamda $Lamda $c $c $c $D $D;
        element zeroLength $SpringID $NodeI $NodeJ -mat 99 99 $SpringID -dir 1 2 6;
        # element zeroLength $SpringID $NodeI $NodeJ -mat $SpringID -dir 6;
        # equalDOF $NodeI $NodeJ 1 2;
        if {$check ne ""} {
            puts "$check:\nKs: $K, My: $My, theta_p: $theta_p, theta_pc: $theta_pc, Res: $Res"
        }
    }

}