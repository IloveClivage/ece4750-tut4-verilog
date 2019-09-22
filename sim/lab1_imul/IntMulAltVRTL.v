//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_ALT_V
`define LAB1_IMUL_INT_MUL_ALT_V

`include "vc/trace.v"

// ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
// Define datapath and control unit here.
// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

module shifter
( 
  input logic clk,
  input logic reset,
  
  input logic rdy,
  input logic [31:0] req_msga,
  input logic [31:0] req_msgb,
  output logic[31:0] shifted_a,
  output logic b_0,
  output resp_val,
  output logic [4:0] judge_0,
  output logic [5:0] counter2,
  output logic [31:0] output_a
);

logic [31:0] reg_a;
logic [31:0] reg_b;
logic [31:0] reg_b_shift;
logic [31:0] reg_b_shift_1;
logic [31:0] temp;
logic [31:0] gandongshijie;

logic [5:0] counter;

logic [4:0] flag_zeros; 

always @(posedge clk) begin 
  if (!reset) begin
    if (rdy) begin
      reg_a <= req_msga;
      reg_b <= req_msgb;
      reg_b_shift_1 <= (req_msgb >> 1) - 1;
      reg_b_shift <= (req_msgb >> 1);
      counter <= 0;
    end
    else begin
      reg_b <= reg_b >> (flag_zeros+1);
      reg_b_shift <= (reg_b >> (flag_zeros+2));
      reg_b_shift_1 <= (reg_b >> (flag_zeros+2)) - 1;
      counter <= counter + (flag_zeros+1);
      reg_a <= reg_a << (flag_zeros+1);
    end
  end
  else begin
    reg_a <= 0;
    reg_b <= 0;
    counter <= 0;
    reg_b_shift_1 <= 0;
    reg_b_shift <= 0;
  end
end

assign shifted_a = reg_a;
assign b_0 = reg_b[0];

assign flag_zeros[0] = gandongshijie[1]+gandongshijie[3]+gandongshijie[5]+gandongshijie[7]+gandongshijie[9]+gandongshijie[11]+gandongshijie[13]+gandongshijie[15]+gandongshijie[17]+gandongshijie[19]+gandongshijie[21]+gandongshijie[23]+gandongshijie[25]+gandongshijie[27]+gandongshijie[29]+gandongshijie[31];
assign flag_zeros[1] = gandongshijie[2]+gandongshijie[3]+gandongshijie[6]+gandongshijie[7]+gandongshijie[10]+gandongshijie[11]+gandongshijie[14]+gandongshijie[15]+gandongshijie[18]+gandongshijie[19]+gandongshijie[22]+gandongshijie[23]+gandongshijie[26]+gandongshijie[27]+gandongshijie[30]+gandongshijie[31];
assign flag_zeros[2] = gandongshijie[4]+gandongshijie[5]+gandongshijie[6]+gandongshijie[7]+gandongshijie[12]+gandongshijie[13]+gandongshijie[14]+gandongshijie[15]+gandongshijie[20]+gandongshijie[21]+gandongshijie[22]+gandongshijie[23]+gandongshijie[28]+gandongshijie[29]+gandongshijie[30]+gandongshijie[31];
assign flag_zeros[3] = gandongshijie[8]+gandongshijie[9]+gandongshijie[10]+gandongshijie[11]+gandongshijie[12]+gandongshijie[13]+gandongshijie[14]+gandongshijie[15]+gandongshijie[24]+gandongshijie[25]+gandongshijie[26]+gandongshijie[27]+gandongshijie[28]+gandongshijie[29]+gandongshijie[30]+gandongshijie[31];
assign flag_zeros[4] = gandongshijie[16]+gandongshijie[17]+gandongshijie[18]+gandongshijie[19]+gandongshijie[20]+gandongshijie[21]+gandongshijie[22]+gandongshijie[23]+gandongshijie[24]+gandongshijie[25]+gandongshijie[26]+gandongshijie[27]+gandongshijie[28]+gandongshijie[29]+gandongshijie[30]+gandongshijie[31];
assign judge_0 = flag_zeros;
assign counter2 = counter;
assign temp = (reg_b_shift^reg_b_shift_1);
assign gandongshijie = ((~temp) >> 1)&temp;
assign output_a = reg_a;


assign resp_val = counter > 31;

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

//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

module lab1_imul_IntMulAltVRTL
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
  
  logic [1:0] state;
  assign rdy = (state == 0) & req_val;
  
  logic r_val;
  logic [4:0] judge_0;
  logic [5:0] counter2;
  logic [31:0] output_a;
  
  shifter Shifter(.clk(clk), .reset(reset), .rdy(rdy), .req_msga(req_msg[63:32]), .req_msgb(req_msg[31:0]), .shifted_a(shifted_a), .b_0(b_0), .resp_val(r_val), .judge_0(judge_0), .counter2(counter2), .output_a(output_a));
  adder Adder(.clk(clk), .reset(reset), .result_sel(rdy), .add_sel(b_0), .shifted_a(shifted_a), .resp_msg(resp_msg));
  
  assign resp_val = r_val & state == 1;
  
  always @(posedge clk) begin
    if (!reset) begin
      if (req_val & state == 0) begin
        state <= 1;
        req_rdy <= 1;
      end
      if (state == 1) begin
        req_rdy <= 0;
        if (resp_val)
          state <= 2;
      end
      else if (resp_rdy & state == 2) begin
        state <= 0;
      end
    end
    else begin
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
    
    $sformat( str, "%x", req_msg[63:0] );
    vc_trace.append_str( trace_str, str);
    vc_trace.append_str( trace_str, " n_0:" );
    
    $sformat( str, "%x", judge_0[4:0] );
    vc_trace.append_str( trace_str, str);
    vc_trace.append_str( trace_str, " counter:" );
    
    $sformat( str, "%x", counter2[5:0] );
    vc_trace.append_str( trace_str, str);
    vc_trace.append_str( trace_str, " a:" );
    
    $sformat( str, "%x", output_a);
    vc_trace.append_str( trace_str, str);
    vc_trace.append_str( trace_str, " result:" );
    
    $sformat( str, "%x", resp_msg);
    vc_trace.append_str( trace_str, str);
    vc_trace.append_str( trace_str, " " );
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

`endif /* LAB1_IMUL_INT_MUL_ALT_V */
