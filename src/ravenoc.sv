/**
 * File: ravenoc.sv
 * Description: RaveNoC top module
 * Author: Anderson Ignacio da Silva <anderson@aignacio.com>
 *
 * MIT License
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module ravenoc #(
  parameter bit [NoCSize-1:0] AXI_CDC_REQ = '1
) (
  input                [NoCSize-1:0] clk_axi,
  input                              clk_noc,
  input                [NoCSize-1:0] arst_axi,
  input                              arst_noc,
  // NI interfaces
  input   s_axi_mosi_t [NoCSize-1:0] axi_mosi_if,
  output  s_axi_miso_t [NoCSize-1:0] axi_miso_if,
  // IRQs
  output  s_irq_ni_t   [NoCSize-1:0] irqs,
  // Used only in tb to bypass cdc module
  input                [NoCSize-1:0] bypass_cdc
);

  // Import packages inside the body
  import ravenoc_pkg::*;
  import amba_axi_pkg::*;

  router_if ns_con  [(NoCCfgSzRows+1)*NoCCfgSzCols] ();
  router_if sn_con  [(NoCCfgSzRows+1)*NoCCfgSzCols] ();
  router_if we_con  [NoCCfgSzRows*(NoCCfgSzCols+1)] ();
  router_if ew_con  [NoCCfgSzRows*(NoCCfgSzCols+1)] ();

  for (genvar x = 0; x < NoCCfgSzRows; x++) begin : gen_noc_x_lines
    for (genvar y = 0; y < NoCCfgSzCols; y++) begin : gen_noc_y_columns
      localparam s_router_ports_t Router = router_ports(x, y);
      localparam int LocalIdx = y + x * (NoCCfgSzCols);
      localparam int NorthIdx = y + x * (NoCCfgSzCols);
      localparam int SouthIdx = y + ((x + 1) * NoCCfgSzCols);
      localparam int WestIdx  = y + (x * (NoCCfgSzCols + 1));
      localparam int EastIdx  = (y + 1) + (x * (NoCCfgSzCols + 1));

      router_wrapper #(
        .ROUTER_X_ID(x),
        .ROUTER_Y_ID(y),
        .CDC_REQUIRED(AXI_CDC_REQ[LocalIdx])
      ) u_router_wrapper (
        .clk_axi        (clk_axi[LocalIdx]),
        .clk_noc        (clk_noc),
        .arst_axi       (arst_axi[LocalIdx]),
        .arst_noc       (arst_noc),
        .north_send     (ns_con[NorthIdx]),
        .north_recv     (sn_con[NorthIdx]),
        .south_send     (sn_con[SouthIdx]),
        .south_recv     (ns_con[SouthIdx]),
        .west_send      (we_con[WestIdx]),
        .west_recv      (ew_con[WestIdx]),
        .east_send      (ew_con[EastIdx]),
        .east_recv      (we_con[EastIdx]),
        .axi_mosi_if_i  (axi_mosi_if[LocalIdx]),
        .axi_miso_if_o  (axi_miso_if[LocalIdx]),
        .irqs_o         (irqs[LocalIdx]),
        .bypass_cdc_i   (bypass_cdc[LocalIdx])
      );

      if (~Router.north_req) begin : gen_north_dummy
        ravenoc_dummy u_north_dummy (
          .local_port('0),
          .recv(ns_con[NorthIdx]),
          .send(sn_con[NorthIdx])
        );
      end

      if (~Router.south_req) begin : gen_south_dummy
        ravenoc_dummy u_south_dummy (
          .local_port('0),
          .recv(sn_con[SouthIdx]),
          .send(ns_con[SouthIdx])
        );
      end

      if (~Router.west_req) begin : gen_west_dummy
        ravenoc_dummy u_west_dummy (
          .local_port('0),
          .recv(we_con[WestIdx]),
          .send(ew_con[WestIdx])
        );
      end

      if (~Router.east_req) begin : gen_east_dummy
        ravenoc_dummy u_east_dummy (
          .local_port('0),
          .recv(ew_con[EastIdx]),
          .send(we_con[EastIdx])
        );
      end
    end
  end

  function automatic s_router_ports_t router_ports(int x, int y);
    s_router_ports_t connected_ports;
    connected_ports.north_req = (x > 0)                ? 1 : 0;
    connected_ports.south_req = (x < (NoCCfgSzRows-1)) ? 1 : 0;
    connected_ports.west_req  = (y > 0)                ? 1 : 0;
    connected_ports.east_req  = (y < (NoCCfgSzCols-1)) ? 1 : 0;
    connected_ports.local_req = 0;
    return connected_ports;
  endfunction

endmodule

module ravenoc_dummy (
  input                 local_port,
  router_if.send_flit   send,
  router_if.recv_flit   recv
);
  always_comb begin
    if (local_port == 0) begin
      recv.resp = '0;
      send.req  = '0;
    end else begin
      recv.resp = '1;
      send.req  = '0;
    end
  end
endmodule
