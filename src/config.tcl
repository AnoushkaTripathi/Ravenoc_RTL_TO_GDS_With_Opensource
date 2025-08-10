# ==============================================
# Ravenoc OpenLane Config (GitHub Actions Friendly)
# ==============================================

# Platform and design name
set ::env(PLATFORM) "sky130hd"
set ::env(DESIGN_NAME) "ravenoc"

# Collect include directories (relative to DESIGN_DIR)
set verilog_includes {
    "$::env(DESIGN_DIR)/include"
    "$::env(DESIGN_DIR)/src"
    "$::env(DESIGN_DIR)/ni"
    "$::env(DESIGN_DIR)/router"
}
set ::env(VERILOG_INCLUDE_DIRS) $verilog_includes

# Collect all RTL/SystemVerilog files
set verilog_files {}
foreach dir {"src" "include" "ni" "router"} {
    if {[file isdirectory "$::env(DESIGN_DIR)/$dir"]} {
        foreach f [exec find "$::env(DESIGN_DIR)/$dir" -type f \( -iname "*.sv" -o -iname "*.v" \)] {
            lappend verilog_files $f
        }
    }
}
set ::env(VERILOG_FILES) $verilog_files

# Constraints file
set ::env(SDC_FILE) "$::env(DESIGN_DIR)/router/base.sdc"

# Clock config
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10.0"

# Synthesis options
set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(SYNTH_READ_BLACKBOX_LIB) 1

