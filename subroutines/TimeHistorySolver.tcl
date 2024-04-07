# -------------------------- Time history analysis --------------------------
#
# Args (16):
# ---------------
# dt_init           Ground motion step
# duration          Ground motion duration
# story_heights     Heights of story
# ctrl_nodes        Controlled nodes of story
# CollapseDrift     Drift ratio that sign the frame as collapse
# MaxAnalysisDrift  Drift ratio that analysis termination
# GMname            Ground motion name
# maxRunTime        Maximum run time (second)
# temp              Temp folder
# min_factor        Factor to control the adaptive time step
# max_factor        Factor to control the adaptive time step

# ---------------
# Written by: Wenchen Lie, Guangzhou University, China
# Date: 2024-04-07
# --------------------------------------------------------------------------------

proc TimeHistorySolver {
    dt_init duration story_heights ctrl_nodes CollapseDrift MaxAnalysisDrift
    GMname maxRunTime temp {min_factor 1e-6} {max_factor 1}} {

    set algorithms [list KrylovNewton NewtonLineSearch Newton SecantNewton];
    set algorithm_id 0;

    wipeAnalysis;
    constraints Plain;
    numberer RCM;
    system UmfPack;
    test EnergyIncr 1.0e-3 100;
    algorithm KrylovNewton;
    integrator Newmark 0.5 0.25;
    analysis Transient;

    set collapse_flag 0;
    set print_collapse 1;
    set factor 1;
    set start_time [clock seconds];
    set nstep 0;

    set dt $dt_init
    while {1} {
        if {[expr [clock seconds] - $start_time] >= $maxRunTime} {
            puts "Exceeding maximum running time";
            return [list 4 [getTime]];
        }
        set ok [analyze 1 $dt];
        if {$ok == 0} {
            if {[getTime] >= $duration} {
                puts "Analysis finished";
                return [list 1 [getTime]];
            }
            set test_result [SDR_tester $story_heights $ctrl_nodes $CollapseDrift $MaxAnalysisDrift $GMname $temp]
            set collapse_flag [lindex $test_result 0]
            set maxAna_flag [lindex $test_result 1]
            if {$maxAna_flag} {
                puts "Analysis finished, the structure collapsed"
                return [list 2 [getTime]]
            }
            if {$collapse_flag && $print_collapse} {
                puts "The structure was collapse"
                set print_collapse 0
            }
            set factor_old $factor
            set factor [expr {min($factor * 2, $max_factor)}]
            if {$factor_old < $factor} {
                puts "---- Enlarged factor: $factor"
            }
            incr algorithm_id -1
            set algorithm_id [expr {max(0, $algorithm_id)}]
        } else {
            set factor [expr {$factor * 0.5}]
            if {$factor < $min_factor} {
                set factor $min_factor
                incr algorithm_id
                if {$algorithm_id == 4} {
                    puts "Cannot converge"
                    return [list 3 [getTime]]
                }
                puts "-------- Switched algorithm: [lindex $algorithms $algorithm_id]"
            }
            puts "---- Reduced factor: $factor"
        }
        set dt [expr {$factor * $dt_init}]
        if {[expr $dt + [getTime]] > $duration} {
            set dt [expr $duration - [getTime]]
            if {[expr abs($dt)] < 1e-8} {return [list 1 [getTime]]}
        }
        algorithm [lindex $algorithms $algorithm_id]
        incr nstep
    }
}


proc SDR_tester {story_heights ctrl_nodes CollapseDrift MaxAnalysisDrift GMname temp} {
    if {$CollapseDrift > $MaxAnalysisDrift} {
        error "`MaxAnalysisDrift` should be larger than `CollapseDrift`"
    }

    for {set i 0} {$i < [llength $story_heights]} {incr i} {
        set h [lindex $story_heights $i]
        if {$i == 0} {
            set disp_b 0
            set disp_t [lindex [nodeDisp [lindex $ctrl_nodes 0]] 0]
        } else {
            set disp_b [lindex [nodeDisp [lindex $ctrl_nodes [expr {$i - 1}]]] 0]
            set disp_t [lindex [nodeDisp [lindex $ctrl_nodes $i]] 0]
        }
        set SDR [expr {abs($disp_t - $disp_b) / $h}]
        if {$SDR >= $MaxAnalysisDrift} {
            return [list 1 1]
        }
        if {$SDR >= $CollapseDrift} {
            set f [open "$temp/${GMname}_CollapseState.txt" w]
            puts $f "1"
            close $f
            return [list 1 0]
        }
    }
    return [list 0 0]
}
