# Design name
set ::env(DESIGN_NAME) ravenoc

# Paths
set ::env(DESIGN_HOME) $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)
set ::env(DESIGN_DIR)  $::env(DESIGN_HOME)/src
set verilog_files ""

# Explicit header includes
lappend verilog_files \
    $::env(DESIGN_DIR)/misc/ravenoc_defines.svh \
    $::env(DESIGN_DIR)/ravenoc/include/ravenoc_structs.svh \
    $::env(DESIGN_DIR)/ravenoc/include/ravenoc_axi_structs.svh \
    $::env(DESIGN_DIR)/ravenoc/include/ravenoc_axi_fnc.svh \
    $::env(DESIGN_DIR)/ravenoc/include/ravenoc_pkg.sv

# Recursively find .sv in ravenoc
foreach f [exec find $::env(DESIGN_DIR) -type f -iname "*.sv"] {
    lappend verilog_files $f
}

# Recursively find .v in verilog-axi
foreach f [exec find $::env(DESIGN_DIR)/router -type f -iname "*.sv"] {
    lappend verilog_files $f
}

# Recursively find .sv in misc
foreach f [exec find $::env(DESIGN_DIR)/ni  -type f -iname "*.sv"] {
    lappend verilog_files $f
}


# Assign to OpenLane env var
set ::env(VERILOG_FILES) $verilog_files

# Constraints and config files
set ::env(SDC_FILE)   $::env(DESIGN_HOME)/base.sdc
set ::env(CONFIG_TCL) $::env(DESIGN_HOME)/config.tcl
