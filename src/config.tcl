# ========================================
# Platform and Design
# ========================================
set ::env(PLATFORM)        "sky130"
set ::env(DESIGN_NICKNAME) "ravenoc"
set ::env(DESIGN_NAME)     "ravenoc"

# ========================================
# Directories
# ========================================
set ::env(DESIGN_HOME) "/work"        ;# repo root in container
set ::env(DESIGN_DIR)  $::env(DESIGN_HOME)

# ========================================
# Verilog Include Directories
# ========================================
set verilog_includes [list \
    "$::env(DESIGN_HOME)/include" \
    "$::env(DESIGN_HOME)/ni" \
    "$::env(DESIGN_HOME)/router" \
]
set ::env(VERILOG_INCLUDE_DIRS) $verilog_includes

# ========================================
# Collect Verilog/SystemVerilog Files
# ========================================
set verilog_files [list \
    "$::env(DESIGN_HOME)/include/ravenoc_defines.svh" \
    "$::env(DESIGN_HOME)/include/ravenoc_structs.svh" \
    "$::env(DESIGN_HOME)/include/ravenoc_axi_structs.svh" \
    "$::env(DESIGN_HOME)/include/ravenoc_axi_fnc.svh" \
    "$::env(DESIGN_HOME)/include/ravenoc_pkg.sv" \
]

# Add all .sv files from src/, ni/, router/
foreach dir {"src" "ni" "router"} {
    foreach file [exec find $::env(DESIGN_HOME)/$dir -type f -iname "*.sv" | sort] {
        lappend verilog_files $file
    }
}

set ::env(VERILOG_FILES) $verilog_files

# ========================================
# Constraints
# ========================================
if {[info exists ::env(FLOW_VARIANT)] && $::env(FLOW_VARIANT) eq "pos_slack"} {
    set ::env(SDC_FILE) "$::env(DESIGN_HOME)/$::env(PLATFORM)/$::env(DESIGN_NICKNAME)/constraint_pos_slack.sdc"
} else {
    set ::env(SDC_FILE) "$::env(DESIGN_HOME)/$::env(PLATFORM)/$::env(DESIGN_NICKNAME)/constraint.sdc"
}

# ========================================
# Floorplanning
# ========================================
set ::env(CORE_UTILIZATION)       40
set ::env(CORE_ASPECT_RATIO)      1
set ::env(CORE_MARGIN)            2
set ::env(PLACE_DENSITY_LB_ADDON) 0.20

# ========================================
# Flow Toggles
# ========================================
set ::env(ENABLE_DPO)       0
set ::env(TNS_END_PERCENT)  100
