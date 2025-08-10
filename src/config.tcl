# ==============================================
# Ravenoc OpenLane Config (GitHub Actions Friendly)
# ==============================================
# Name of the top-level module
set ::env(DESIGN_NAME) ravenoc

# Path to the directory containing this config.tcl
set ::env(DESIGN_DIR) $::env(DESIGN_DIR)

# Collect include directories (relative to DESIGN_DIR)
set verilog_includes {
    "$::env(DESIGN_DIR)/include"
    "$::env(DESIGN_DIR)/src"
    "$::env(DESIGN_DIR)/ni"
    "$::env(DESIGN_DIR)/router"
}
set ::env(VERILOG_INCLUDE_DIRS) $verilog_includes

# Collect all RTL/SystemVerilog files
# List all RTL .sv files
set ::env(VERILOG_FILES) "\
    $::env(DESIGN_DIR)/ravenoc.sv \
    $::env(DESIGN_DIR)/ravenoc_wrapper.sv \
    $::env(DESIGN_DIR)/ni/async_gp_fifo.sv \
    $::env(DESIGN_DIR)/ni/axi_csr.sv \
    $::env(DESIGN_DIR)/ni/axi_slave_if.sv \
    $::env(DESIGN_DIR)/ni/cdc_pkt.sv \
    $::env(DESIGN_DIR)/ni/pkt_proc.sv \
    $::env(DESIGN_DIR)/ni/router_wrapper.sv \
    $::env(DESIGN_DIR)/router/fifo.sv \
    $::env(DESIGN_DIR)/router/input_datapath.sv \
    $::env(DESIGN_DIR)/router/input_module.sv \
    $::env(DESIGN_DIR)/router/input_router.sv \
    $::env(DESIGN_DIR)/router/output_module.sv \
    $::env(DESIGN_DIR)/router/router_if.sv \
    $::env(DESIGN_DIR)/router/router_ravenoc.sv \
    $::env(DESIGN_DIR)/router/rr_arbiter.sv \
    $::env(DESIGN_DIR)/router/vc_buffer.sv \
"

set ::env(SYNTH_HDL_FRONTEND) "slang"

# ============================================================
# Floorplan & Placement settings
# ============================================================

# Put all pins on the left
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

# Reduce wasted space
set ::env(TOP_MARGIN_MULT) 2
set ::env(BOTTOM_MARGIN_MULT) 2

# Absolute die size
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 90 120"
set ::env(FP_CORE_UTIL) 45
set ::env(PL_BASIC_PLACEMENT) {1}

set ::env(FP_IO_HLENGTH) 2
set ::env(FP_IO_VLENGTH) 2

# ============================================================
# Power & Routing settings
# ============================================================

# Use efabless decap cells to solve LI density issues
set ::env(DECAP_CELL) "\
    sky130_fd_sc_hd__decap_3 \
    sky130_fd_sc_hd__decap_4 \
    sky130_fd_sc_hd__decap_6 \
    sky130_fd_sc_hd__decap_8 \
    sky130_ef_sc_hd__decap_12"

# No power rings, limit to met4
set ::env(DESIGN_IS_CORE) 0
set ::env(RT_MAX_LAYER) {met4}

# Power nets
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

# ============================================================
# Misc settings
# ============================================================

# Skip KLayout checks during dev
set ::env(RUN_KLAYOUT_XOR) 0
set ::env(RUN_KLAYOUT_DRC) 0

# Don’t buffer output ports
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

# Allow use of specific sky130 cells
set ::env(SYNTH_READ_BLACKBOX_LIB) 1

# Clock (set to none here)
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(CLOCK_PORT) ""
