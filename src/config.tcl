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

# Constraints file
set ::env(SDC_FILE) "$::env(DESIGN_DIR)/router/base.sdc"
set ::env(DECAP_CELL) "\
    sky130_fd_sc_hd__decap_3 \
    sky130_fd_sc_hd__decap_4 \
    sky130_fd_sc_hd__decap_6 \
    sky130_fd_sc_hd__decap_8 \
    sky130_ef_sc_hd__decap_12"

# Clock config
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10.0"

# Synthesis options
set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(SYNTH_READ_BLACKBOX_LIB) 1

