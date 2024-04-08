

proc PushoverAnalysis {CtrlNode Dmax Dincr_init {min_factor 1e-6} {max_factor 1}} {

    wipeAnalysis
    constraints Plain
    numberer RCM
    system UmfPack
    test EnergyIncr 1.e-5 30
    analysis Static

    set ls_algorithm [list KrylovNewton NewtonLineSearch Newton SecantNewton]
    set Id_algorithm 0
    set factor 1.0
    set start_time [clock seconds]

    set Dincr $Dincr_init
    while {1} {
        if {[expr [clock seconds] - $start_time] >= $maxRunTime} {
            puts "Exceeding maximum running time"
            return [list 4 [nodeDisp $CtrlNode]]
        }
        algorithm [lindex $ls_algorithm $Id_algorithm]
        integrator DisplacementControl $CtrlNode 1 $Dincr
        set ok [analyze 1];
        if {$ok == 0} {
            if {[nodeDisp $CtrlNode] >= $Dmax} {
                puts "Analysis finished";
                return [list 1 [nodeDisp $CtrlNode]];
            }
            set factor_old $factor
            set factor [expr {min($factor * 2, $max_factor)}]
            if {$factor_old < $factor} {
                puts "-- [nodeDisp $CtrlNode] -- Enlarged factor: $factor"
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
                    return [list 3 [nodeDisp $CtrlNode]]
                }
                puts "-- [nodeDisp $CtrlNode] ------ Switched algorithm: [lindex $algorithms $algorithm_id]"
            }
            puts "-- [nodeDisp $CtrlNode] -- Reduced factor: $factor"
        }
        set Dincr [expr $factor * $Dincr_init]
    }

}







