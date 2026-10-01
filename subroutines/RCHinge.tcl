####################################################################################################
# RCHinge -- concentrated RC beam/column plastic hinge
#
# The yield moment uses the Panagiotakos--Fardis approximation.  The deformation
# and deterioration relations use Haselton et al. (2016), including the
# non-symmetric reinforcement correction in Eq. (7).
# Model units are N, mm, and MPa when Units=1.
#
# Arguments:
#   SpringID, NodeI, NodeJ : zeroLength element/material tag and end-node tags
#   fc, Ec, fy, Es         : expected material strengths and elastic moduli
#   b, h                   : section width and bending depth
#   dTop, dBottom          : bar-centroid depths from the corresponding concrete faces
#   s                      : stirrup spacing (retained for the reference-model interface)
#   rhoTop, rhoBottom      : gross-area top and bottom longitudinal reinforcement ratios
#   rhoI, rhoSH            : gross-area side-bar ratio and effective stirrup ratio
#   a_sl                   : bond-slip indicator (0 or 1)
#   PPc                    : gross axial-load ratio P/(b*h*fc)
#   Units                  : 1=mm/MPa, 2=inch/ksi
#   L, EIyEIg, n           : clear length, EI reduction ratio, series-stiffness multiplier
#   Reverse                : 1 swaps positive/negative yield moments at the opposite member end
####################################################################################################

proc _RCYieldMoment {b h dCompression dTension areaT areaC areaI P fc Ec fy Es c_unit} {
    # Tcl performs integer division when both operands are integers.  Use an
    # explicit floating operand in every physical ratio so calls such as
    # ``RCHinge ... 40 30000 460 200000 ...`` remain valid.
    set d [expr {double($h)-$dTension}]
    set delta1 [expr {double($dCompression)/$d}]
    set rhoT [expr {double($areaT)/$b/$d}]
    set rhoC [expr {double($areaC)/$b/$d}]
    set rhoI [expr {double($areaI)/$b/$d}]
    set effectiveDepthAxialRatio [expr {double($P)/$b/$d/$fc}]
    set modular_ratio [expr {double($Es)/$Ec}]
    set esy [expr {double($fy)/$Es}]
    set ecu 0.003
    set fcMPa [expr {$fc*$c_unit}]
    if {$fcMPa <= 27.6} {
        set beta1 0.85
    } elseif {$fcMPa >= 55.16} {
        set beta1 0.65
    } else {
        set beta1 [expr {1.05-0.05*$fcMPa/6.9}]
    }
    set c [expr ($areaT*$fy-$areaC*$fy+$P)/(0.85*$fc*$beta1*$b)]
    set cb [expr $ecu*$d/($ecu+$esy)]
    if {$c < $cb} {
        set A [expr $rhoT+$rhoC+$rhoI+$effectiveDepthAxialRatio*$fc/$fy]
        set B [expr $rhoT+$rhoC*$delta1+0.5*$rhoI*(1+$delta1)+$effectiveDepthAxialRatio*$fc/$fy]
        set ky [expr sqrt($modular_ratio*$modular_ratio*$A*$A+2*$modular_ratio*$B)-$modular_ratio*$A]
        set curv_y [expr {$esy/(1.0-$ky)/$d}]
    } else {
        set A [expr $rhoT+$rhoC+$rhoI-$effectiveDepthAxialRatio/1.8/$modular_ratio]
        set B [expr $rhoT+$rhoC*$delta1+0.5*$rhoI*(1+$delta1)]
        set ky [expr sqrt($modular_ratio*$modular_ratio*$A*$A+2*$modular_ratio*$B)-$modular_ratio*$A]
        set curv_y [expr 1.8*$fc/($Ec*$d*$ky)]
    }
    set term1 [expr {$Ec*$ky*$ky/2.0*(0.5*(1.0+$delta1)-$ky/3.0)}]
    set term2 [expr {$Es/2.0*((1.0-$ky)*$rhoT+($ky-$delta1)*$rhoC+$rhoI/6.0*(1.0-$delta1))*(1.0-$delta1)}]
    set My [expr $b*$d*$d*$d*$curv_y*($term1+$term2)]
    return $My
}

proc RCHinge {SpringID NodeI NodeJ fc Ec fy Es b h dTop dBottom s rhoTop rhoBottom rhoI rhoSH a_sl PPc Units L EIyEIg n Reverse} {
    # Normalize values that are commonly emitted as integer-looking Tcl
    # literals.  This protects all downstream expressions from integer math.
    set fc [expr {double($fc)}]
    set Ec [expr {double($Ec)}]
    set fy [expr {double($fy)}]
    set Es [expr {double($Es)}]
    set b [expr {double($b)}]
    set h [expr {double($h)}]
    set L [expr {double($L)}]
    set EIyEIg [expr {double($EIyEIg)}]
    set n [expr {double($n)}]
    if {$Units == 1} {
        set c_unit 1.0
    } else {
        set c_unit 6.895
    }
    set areaTop [expr $rhoTop*$b*$h]
    set areaBottom [expr $rhoBottom*$b*$h]
    set areaI [expr $rhoI*$b*$h]
    set P [expr $PPc*$b*$h*$fc]
    set MyPos [_RCYieldMoment $b $h $dTop $dBottom $areaBottom $areaTop $areaI $P $fc $Ec $fy $Es $c_unit]
    set MyNeg [_RCYieldMoment $b $h $dBottom $dTop $areaTop $areaBottom $areaI $P $fc $Ec $fy $Es $c_unit]
    set thetaPSymmetric [expr 0.1*(1+0.55*$a_sl)*pow(0.16,$PPc)*pow(0.02+40*$rhoSH,0.43)*pow(0.54,0.01*$c_unit*$fc)]
    set positiveDepth [expr {$h-$dBottom}]
    set negativeDepth [expr {$h-$dTop}]
    set rhoTPos [expr {$areaBottom/$b/$positiveDepth}]
    set rhoCPos [expr {$areaTop/$b/$positiveDepth}]
    set rhoTNeg [expr {$areaTop/$b/$negativeDepth}]
    set rhoCNeg [expr {$areaBottom/$b/$negativeDepth}]
    set correctionPos [expr {pow(max(0.01,$rhoCPos*$fy/$fc)/max(0.01,$rhoTPos*$fy/$fc),0.225)}]
    set correctionNeg [expr {pow(max(0.01,$rhoCNeg*$fy/$fc)/max(0.01,$rhoTNeg*$fy/$fc),0.225)}]
    set thetaPPos [expr {$thetaPSymmetric*$correctionPos}]
    set thetaPNeg [expr {$thetaPSymmetric*$correctionNeg}]
    if {$Reverse} {
        set swap $MyPos
        set MyPos $MyNeg
        set MyNeg $swap
        set swap $thetaPPos
        set thetaPPos $thetaPNeg
        set thetaPNeg $swap
    }
    set theta_pc [expr min(0.76*pow(0.031,$PPc)*pow(0.02+40*$rhoSH,1.02),0.10)]
    set lambdaIMK [expr 30.0*pow(0.3,$PPc)*min($thetaPPos,$thetaPNeg)]
    set I [expr {$b*$h*$h*$h/12.0*$EIyEIg}]
    set Ke [expr ($n+1.0)*6*$Ec*$I/$L]
    uniaxialMaterial IMKPeakOriented $SpringID $Ke $thetaPPos $theta_pc 0.2 $MyPos 1.13 0.01 $thetaPNeg $theta_pc 0.2 $MyNeg 1.13 0.01 $lambdaIMK $lambdaIMK $lambdaIMK $lambdaIMK 1 1 1 1 1 1
    # puts "$Ke $thetaPPos $theta_pc 0.2 $MyPos 1.13 0.01 $thetaPNeg $theta_pc 0.2 $MyNeg 1.13 0.01 $lambdaIMK $lambdaIMK $lambdaIMK $lambdaIMK 1 1 1 1 1 1"
    element zeroLength $SpringID $NodeI $NodeJ -mat 99 99 $SpringID -dir 1 2 6 -doRayleigh 1
}
