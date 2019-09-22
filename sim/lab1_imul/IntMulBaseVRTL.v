//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`ifndef LAB1_IMUL_INT_MUL_BASE_V
`define LAB1_IMUL_INT_MUL_BASE_V

`include "vc/trace.v"

// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Define datapath and control unit here.
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

module shifter
( 
  input logic clk,
  input logic reset,
  
  input logic rdy,
  input logic [31:0] req_msga,
  input logic [31:0] req_msgb,
  output logic[31:0] shifted_a,
  output logic b_0
);

logic [31:0] reg_a;
logic [31:0] reg_b;

always @(posedge clk) begin 
  if (!reset) begin
    if (rdy) begin
      reg_a <= req_msga;
      reg_b <= req_msgb;
    end
    else begin
      reg_a <= reg_a << 1;
      reg_b <= reg_b >> 1;
    end
  end
  else begin
    reg_a <= 0;
    reg_b <= 0;
  end
end

assign shifted_a = reg_a;
assign b_0 = reg_b[0];

endmodule

module adder(
  input logic clk,
  input logic reset,
  
  input logic result_sel,
  input logic add_sel,
  input logic [31:0] shifted_a,
  output logic [31:0] resp_msg
);

logic [31:0] reg_res;

always @(posedge clk) begin
  if (!reset) begin
    if (result_sel)
      reg_res <= 0;
    else begin
      if (add_sel)
        reg_res <= reg_res + shifted_a;
    end
  end
  else
    reg_res <= 0;
end

assign resp_msg = reg_res;

endmodule


module lab1_imul_IntMulBaseVRTL
(
  input  logic        clk,
  input  logic        reset,

  input  logic        req_val,
  output logic        req_rdy,
  input  logic [63:0] req_msg,

  output logic        resp_val,
  input  logic        resp_rdy,
  output logic [31:0] resp_msg
);

  // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Instantiate datapath and control models here and then connect them
  // together.
  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  logic rdy;
  logic b_0;
  logic [31:0] shifted_a;
  
  logic [5:0] counter;
  logic [1:0] state;
  assign rdy = (state == 0) & req_val;
  
  shifter Shifter(.clk(clk), .reset(reset), .rdy(rdy), .req_msga(req_msg[63:32]), .req_msgb(req_msg[31:0]), .shifted_a(shifted_a), .b_0(b_0));
  adder Adder(.clk(clk), .reset(reset), .result_sel(rdy), .add_sel(b_0), .shifted_a(shifted_a), .resp_msg(resp_msg));
  
  always @(posedge clk) begin
    if (!reset) begin
      if (req_val & state == 0) begin
        state <= 1;
        counter <= 0;
        req_rdy <= 1;
      end
      if (state == 1) begin
        req_rdy <= 0;
        if (counter == 32) begin
          state <= 2;
          resp_val <= 1;
        end
        else
          counter <= counter + 1;
      end
      else if (resp_rdy & state == 2) begin
        state <= 0;
        resp_val <= 0;
      end
    end
    else begin
      counter <= 0;
      state <= 0;
    end
  end
  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x", req_msg );
    vc_trace.append_val_rdy_str( trace_str, req_val, req_rdy, str );

    vc_trace.append_str( trace_str, "(" );
    
    $sformat( str, "%x", rdy );
    vc_trace.append_str( trace_str, str);
    vc_trace.append_str( trace_str, " " );
    
    $sformat( str, "%x", state );
    vc_trace.append_str( trace_str, str);
    vc_trace.append_str( trace_str, " " );
    
    $sformat( str, "%x", req_msg[63:0] );
    vc_trace.append_str( trace_str, str);

    // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
    // Add additional line tracing using the helper tasks for
    // internal state including the current FSM state.
    // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", resp_msg );
    vc_trace.append_val_rdy_str( trace_str, resp_val, resp_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_BASE_V */

