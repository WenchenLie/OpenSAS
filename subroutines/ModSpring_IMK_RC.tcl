##################################################################################################################
# Spring_IMK+RC.tcl
#                                                                                       
# SubRoutine to construct a rotational spring representing the moment-rotation behaviour of an RC beam-column                                                                   
#
# References: 
#--------------	
# Panagiotakos, T. B. and Fardis, M. N. (2001). “Deformations of Reinforced Concrete at Yielding and
#		Ultimate,” ACI Structural Journal, Vol. 98, No. 2, March-April 2001, pp. 135-147.
#
# Haselton, C.B., A.B. Liel, S. T. Lange, and G.G. Deierlein (2008).  "Beam-Column Element Model Calibrated for 
#		Predicting Flexural Response Leading to Global Collapse of RC Frame Buildings", PEER Report 2007/03, 
#		Pacific Engineering Research Center, University of California, Berkeley, California.
#
##################################################################################################################
#
# Input Arguments:
#------------------
# SpringID  Spring ID
# NodeI		Node i ID
# NodeJ		Node j ID
# Ec        Young's modulus of concrete
# fc 		Concrete compressive strength - cylinder
# Ec        Young's modulus of steel rebar
# fy        Yield stress
# b         Section width
# h         Section depth
# d1        Section cover (extreme fiber to reinforcement center)
# s 		Stirrup spacing.
# rho_T 	Area ratio of longitudinal bottom reinforcement (tension)
# rho_C 	Area ratio of longitudinal top reinforcement (compression)
# rho_I 	Area ratio of longitudinal middle reinforcement
# rho_sh 	Area ratio of transverse reinforcement in the plastic hinge region spacing
# a_sl 		Bond-slip indicator at the end of your element (= 1 where bond-slip is possible; typical case  and = 0 if bond-slip is not possible).  Note that bond-slip is important and accounts for 35% of the plastic rotation capacity.
# PPc 		Axial load ratio
# Units		Units: 1 --> mm and MPa     
#				   2 --> inches and ksi
# L         Member length (modified by Lie)
# EIyEIg    Stiffness reduce ratio (modified by Lie)
# type_     1 - beam, 2 - column
# note      One can print the IMK model parameters if "note" is given
# sf        Scale factor of yield moment
#
# gamma     Normalized energy dissipation capacity; it is important to note that this is a normalized value
#			defined by the total energy dissipation capacity of Et = λMyθy. When creating an element
#			model, the input value must be adjusted if an initial stiffness other then EIy/EIg is used.
#
# Written by: Dr. Ahmed Elkady, University of Southampton, UK
# Modified by: Wenchen Lie, Guangzhou University, Guangzhou, China
#
##################################################################################################################


proc ModSpring_IMK_RC {SpringID NodeI NodeJ fc Ec fy Es b h d1 s rho_C rho_T rho_I rho_SH a_sl PPc Units L EIyEIg type_ {note ""} {sf 1.0}} {

# PS by Lie: The terms `fc` and `fy` should be expected strengths.

# set rho_C [expr $rho_C * $sf]
# set rho_T [expr $rho_T * $sf]
# set rho_I [expr $rho_I * $sf]

###################################################################
# Pre-calculation parameters
###################################################################

if {$Units == 1} {
	set c_unit 1.0;
} else {
	set c_unit 6.895;
}

set d 		[expr $h-$d1];
set delta1  [expr $d1/$d];
set P       [expr $PPc*$b*$d*$fc];
set n       [expr $Es/$Ec];
set esy     [expr $fy/$Es];
set ecu     0.003;
set area_T  [expr $rho_T*$b*$d];
set area_C  [expr $rho_C*$b*$d];

###################################################################
# Compute My as per Panagiotakos and Fardis (2001) 
###################################################################

if {$fc < [expr  7.6 / $c_unit]} {
    set beta1 0.85;
} elseif {$fc > [expr 55.17 / $c_unit]} {
    set beta1 0.65;
} else {
    set beta1 [expr 1.05-0.05*($fc/$c_unit/6.9)];
}

set c  [expr ($area_T*$fy - $area_C*$fy + $P)/(0.85*$fc*$beta1*$b)];
set cb [expr ($ecu*$d)/($ecu+$esy)]; # depth of compression block at balanced

if {$c<$cb} {
    set A		[expr $rho_T + $rho_C 		    +     $rho_I + ($P/$b/$d/$fy)];
    set B		[expr $rho_T + $rho_C * $delta1 + 0.5*$rho_I*(1 + $delta1) +($P/$b/$d/$fy)];
    set ky      [expr pow(($n*$n*$A*$A+2*$n*$B),0.5) - $n*$A];
    set curv_y  [expr $fy/$Es/(1 - $ky)/$d];
} else {
	set A		[expr $rho_T + $rho_C+$rho_I - ($P/1.8/$n/$b/$d/$fc)];
	set B		[expr $rho_T + $rho_C*$delta1 + 0.5*$rho_I*(1 + $delta1)];
    set ky      [expr pow(($n*$n*$A*$A+2*$n*$B),0.5) - $n*$A];
    set curv_y  [expr 1.8 * $fc/($Ec*$d*$ky)];
}


set term1	[expr $Ec*pow($ky,2)/2*(0.5*(1 + $delta1) - $ky/3)];
set term2	[expr $Es/2*((1 - $ky)*$rho_T+($ky-$delta1)*$rho_C+$rho_I/6*(1 - $delta1))*(1 - $delta1)];

set My		[expr  $b * pow($d,3)*$curv_y*($term1+$term2)];
set My [expr $sf * $My]

# ------------- calcuated by GB50010 -------------------
# set A_T  [expr $rho_T * $b * $h];
# set A_C  [expr $rho_C * $b * $h];
# set h0 [expr $h - $d1]
# set beta1 0.8
# set a1 1.0;
# set eps_cu [expr 0.0033 - (30. - 50.) * 1.e-5]
# set ksaib [expr $beta1 / (1 + $fy / ($Es * $eps_cu))]
# set a1fcbx [expr $fy * $A_T - $fy * $A_C]
# set x [expr $a1fcbx / $fc / $b]
# set My_p [expr $a1fcbx * ($h0 - $x/2) + $fy * $A_C * ($h0 - $d1)]
# set My_p [expr $My_p * $sf]
# set My_n $My_p
# set My_n [expr $My_n * $sf]
# set a1fcbx_ [expr -$fy * $A_T + $fy * $A_C]
# set x_ [expr $a1fcbx_ / $fc / $b]
# set My_n [expr $a1fcbx_ * ($h0 - $x_/2) + $fy * $A_C * ($h0 - $d1)]






###################################################################
# Compute backbone parameters as per Haselton et al (2008)
###################################################################

# set theta_p  	[expr 0.13 * (1. + 0.55*$a_sl)  * pow(0.130, $PPc) * pow((0.02 + 40*$rho_SH),0.65) * pow(0.57,(0.01*$c_unit*$fc))];
set theta_p  	[expr 0.1 * (1. + 0.55*$a_sl) * pow(0.16, $PPc) * pow((0.02 + 40*$rho_SH), 0.43) * pow(0.54, (0.01*$c_unit*$fc))];  # [1] Eq. (6)
# set theta_p     [expr pow(max(0.01, $rho_C * $fy / $fc) / max(0.01, $rho_T * $fy / $fc), 0.225) * $theta_p];  # Modification for considering non-symmetric reinforcement [2]
set theta_pc 	[expr 0.76 * pow(0.031, $PPc) * pow((0.02 + 40*$rho_SH), 1.02)]; if {$theta_pc > 0.10} {set theta_pc 0.1};  # [1] Eq. (8)
set McMy     	1.13;  # [1] Eq. (9)

set gamma   	[expr 170.7	* pow(0.270,$PPc) * pow(0.10,$s/$d)];  # [1] Eq. (10)
set lambda      [expr 30.0 * pow(0.3, $PPc)];  # [1] Eq. (11)
set LAMBDA      [expr $lambda * $theta_pc];  # Et = Λ*My = γ*θy*My = λ*θcap,pl*My [1]

set n 10.0
# set I [expr 1.0 / 12 * $b * $h ** 3 * $EIyEIg]
set I [expr 1.0 / 12 * $b * $h ** 3]
set Ke [expr ($n + 1.0) * 6 * $Ec * $I / $L];

set MresMy 0.01;
# set theta_y [expr $My / $Ke]
set theta_u 0.2

# TODO
# if {$type_ == 1} {
#     set theta_p 0.035
#     set theta_pc 0.06
# } else {
#     set theta_p 0.06;
#     set theta_pc 0.1
# }



uniaxialMaterial IMKPeakOriented $SpringID $Ke $theta_p $theta_pc $theta_u $My $McMy $MresMy $theta_p $theta_pc $theta_u $My $McMy $MresMy $LAMBDA $LAMBDA $LAMBDA $LAMBDA 1 1 1 1 1 1;
# uniaxialMaterial IMKPeakOriented $SpringID $Ke $theta_p $theta_pc $theta_u $My_p $McMy $MresMy $theta_p $theta_pc $theta_u $My_n $McMy $MresMy $LAMBDA $LAMBDA $LAMBDA $LAMBDA 1 1 1 1 1 1;
element zeroLength $SpringID $NodeI $NodeJ  -mat 99 99 $SpringID -dir 1 2 6 -doRayleigh 1;

if {$note ne ""} {puts "$note:\nKe: [expr int($Ke/1.e6)] kNm, theta_p: [format "%.4f" $theta_p], theta_pc: [format "%.4f" $theta_pc], My_p: [expr int($My_p/1.e6)] My_n: [expr int($My_n/1.e6)], lamda: [format "%.2f" $lambda]"}

}


# [1] Calibration of Model to Simulate Response of Reinforced Concrete Beam-Columns to Collapse, Curt B. Haselton, 2016, ACI Journal.
# [2] Fardis, M. N., and Biskinis, D. E., 2003, “Deformation Capacity of RC Members, as Controlled by Flexure or Shear,” Otani Symposium, pp. 511-530.

# set fy 30
# set Ec 30000
# set fy 400
# set Es 206000
# set b 275
# set h 275
# set d1 25
# set s 50
# set rho_c 0.02
# set rho_T 0.02
# set rho_I 0.0
# set rho_SH 0.0075
# set a_sl 1
# set PPc 0.25
# set Units 1
# Spring_IMK_RC 1 1 1 fc Ec fy Es b h d1 s rho_C rho_T rho_I rho_SH a_sl PPc Units







