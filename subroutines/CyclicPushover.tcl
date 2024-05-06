# -------------------------- Cyclic pushover analysis --------------------------
#
# Args (7):
# ---------------
# CtrlNode          Control node at roof
# RDR_path          Loading path of roof drift ratio
# HBuilding         Heights of the building
# Dincr_init        Initial displacement increment
# maxRunTime        Max run time (s)
# min_factor        Factor to control the adaptive time step
# max_factor        Factor to control the adaptive time step

# ---------------
# Written by: Wenchen Lie, Guangzhou University, China
# Date: 2024-05-06
# --------------------------------------------------------------------------------


proc CyclicPushover {CtrlNode RDR_path HBuilding Dincr_init maxRunTime {min_factor 1e-6} {max_factor 1}} {

    wipeAnalysis
    constraints Plain
    numberer RCM
    system UmfPack
    test EnergyIncr 1.e-5 30
    algorithm KrylovNewton
    integrator DisplacementControl $CtrlNode 1 $Dincr_init
    analysis Static


    foreach RDR $RDR_path {
        
        puts "RDR = $RDR starts"
        set ls_algorithm [list KrylovNewton NewtonLineSearch Newton SecantNewton]
        set Id_algorithm 0
        set factor 1.0
        set start_time [clock seconds]
        set D_target [expr $RDR * $HBuilding]
        if {$D_target >= [nodeDisp $CtrlNode 1]} {
            set direction 1;
        } else {
            set direction -1;
        }
        set Dincr [expr $direction * $Dincr_init]
        while {1} {
            if {[expr [clock seconds] - $start_time] >= $maxRunTime} {
                puts "Exceeding maximum running time"
                return 3
            }
            algorithm [lindex $ls_algorithm $Id_algorithm]
            integrator DisplacementControl $CtrlNode 1 $Dincr
            set ok [analyze 1];
            if {$ok == 0} {
                if {($direction == 1 && [nodeDisp $CtrlNode 1] >= $D_target)} {
                    break
                }
                if {($direction == -1 && [nodeDisp $CtrlNode 1] <= $D_target)} {
                    break
                }
                set factor_old $factor
                set factor [expr {min($factor * 2, $max_factor)}]
                if {$factor_old < $factor} {
                    puts "-- [nodeDisp $CtrlNode 1] -- Enlarged factor: $factor"
                }
                incr Id_algorithm -1
                set Id_algorithm [expr {max(0, $Id_algorithm)}]
            } else {
                set factor [expr {$factor * 0.5}]
                if {$factor < $min_factor} {
                    set factor $min_factor
                    incr Id_algorithm
                    if {$Id_algorithm == 4} {
                        puts "Cannot converge"
                        return 2
                    }
                    puts "-- [nodeDisp $CtrlNode 1] ------ Switched algorithm: [lindex $ls_algorithm $Id_algorithm]"
                }
                puts "-- [nodeDisp $CtrlNode 1] -- Reduced factor: $factor"
            }
            set Dincr [expr $direction * $factor * $Dincr_init]
        }
        puts "RDR = $RDR finished"
    }
    # Analysis finished
    return [list 1 [nodeDisp $CtrlNode 1]];

}







