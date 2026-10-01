# RCJoint2D -- create an RC Joint2D from precomputed material parameters.
#
# MCFT is evaluated by MRFHelper while the model is generated. This subroutine
# receives the resulting Pinching4 envelope and performs no MCFT iteration.
#
# Arguments:
#   JointID                 : element, center-node, and center-material tag
#   NodeB/NodeR/NodeT/NodeL: external-node tags in counter-clockwise order
#   XCenter/YCenter         : joint-center coordinates [mm]
#   ColumnDepth/BeamDepth   : horizontal/vertical joint-core dimensions [mm]
#   PanelModel              : Elastic, Rigid, or Pinching4
#   Elastic args            : JointWidth Ec Nu
#   Rigid args              : JointWidth Ec Nu StiffnessFactor
#   Pinching4 args          : 16 positive/negative envelope values, then
#                             ReloadDisp ReloadForce UnloadForce Degradation
#                             EnergyCapacity DamageType
#
# Side effects: creates four external nodes, one Elastic or Pinching4 center
# material, and one Joint2D element. Joint2D creates its center node internally.
proc RCJoint2D {JointID NodeB NodeR NodeT NodeL XCenter YCenter ColumnDepth BeamDepth PanelModel args} {
    node $NodeB $XCenter [expr {$YCenter-$BeamDepth/2.0}]
    node $NodeR [expr {$XCenter+$ColumnDepth/2.0}] $YCenter
    node $NodeT $XCenter [expr {$YCenter+$BeamDepth/2.0}]
    node $NodeL [expr {$XCenter-$ColumnDepth/2.0}] $YCenter

    set normalized [string tolower [string trim $PanelModel]]
    if {$normalized eq "elastic" || $normalized eq "rigid"} {
        set expected [expr {$normalized eq "elastic" ? 3 : 4}]
        if {[llength $args] != $expected} {
            error "$PanelModel RCJoint2D expects $expected material arguments"
        }
        lassign $args JointWidth Ec Nu StiffnessFactor
        if {$normalized eq "elastic"} {set StiffnessFactor 1.0}
        if {$JointWidth <= 0.0 || $Ec <= 0.0 || $StiffnessFactor <= 0.0 || $Nu <= -1.0 || $Nu >= 0.5} {
            error "Invalid elastic RC joint-panel properties"
        }
        set G [expr {$Ec/(2.0*(1.0+$Nu))}]
        set Ktheta [expr {$G*$JointWidth*$ColumnDepth*$BeamDepth*$StiffnessFactor}]
        uniaxialMaterial Elastic $JointID $Ktheta
    } elseif {$normalized eq "pinching4"} {
        if {[llength $args] != 22} {error "Pinching4 RCJoint2D expects 22 material arguments"}
        set envelope [lrange $args 0 15]
        lassign [lrange $args 16 end] ReloadDisp ReloadForce UnloadForce Degradation EnergyCapacity DamageType
        set pinching [list $ReloadDisp $ReloadForce $UnloadForce $ReloadDisp $ReloadForce $UnloadForce]
        set degradation [lrepeat 15 $Degradation]
        set command [concat [list uniaxialMaterial Pinching4 $JointID] $envelope $pinching $degradation [list $EnergyCapacity $DamageType]]
        eval $command
    } else {
        error "PanelModel must be one of: Elastic, Rigid, Pinching4"
    }
    element Joint2D $JointID $NodeB $NodeR $NodeT $NodeL $JointID $JointID 0
}
