module pipe_IF_ID #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
    )(
       input Clk, Rst, Flush, WEn,

       input [ADDR_WIDTH-1:0] PC_in,
       input [DATA_WIDTH-1:0] IM_in,

       output [ADDR_WIDTH-1:0] PC_out,
       output [DATA_WIDTH-1:0] IM_out
       );

//   struct packed {
//        logic [ADDR_WIDTH-1:0] PC;
//        logic [DATA_WIDTH-1:0] IM;
//   } IF_ID;
   
   reg [ADDR_WIDTH-1:0] IF_ID_PC;
   reg [DATA_WIDTH-1:0] IF_ID_IM;

   always @(posedge Clk) begin
        if (Rst) begin
            IF_ID_PC <= 0;
            IF_ID_IM <= 0;
        end
        else if (Flush) begin
            IF_ID_IM  <= 32'h0000_0013;   // Canonical NOP
            IF_ID_PC  <= 0;
        end
        else if (WEn) begin
            IF_ID_PC  <= PC_in;
            IF_ID_IM  <= IM_in;
        end
        // else - hold previous data
   end

   assign PC_out  = IF_ID_PC;
   assign IM_out  = IF_ID_IM;

endmodule


module pipe_ID_EX #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
    )(
       input Clk, Rst, Flush,

       input [ADDR_WIDTH-1:0] PC_in,
       input [DATA_WIDTH-1:0] Rs1_in,
       input [DATA_WIDTH-1:0] Rs2_in,
       input [DATA_WIDTH-1:0] Imm_in,
       input [DATA_WIDTH-1:0] IM_in,

       output [ADDR_WIDTH-1:0] PC_out,
       output [DATA_WIDTH-1:0] Rs1_out,
       output [DATA_WIDTH-1:0] Rs2_out,
       output [DATA_WIDTH-1:0] Imm_out,
       output [DATA_WIDTH-1:0] IM_out
       );

   reg [ADDR_WIDTH-1:0] ID_EX_PC;
   reg [DATA_WIDTH-1:0] ID_EX_RS1;
   reg [DATA_WIDTH-1:0] ID_EX_RS2;
   reg [DATA_WIDTH-1:0] ID_EX_IMM;
   reg [DATA_WIDTH-1:0] ID_EX_IM;

   always @(posedge Clk) begin
        if (Rst) begin
            ID_EX_PC  <= 0;
            ID_EX_RS1 <= 0;
            ID_EX_RS2 <= 0;
            ID_EX_IMM <= 0;
            ID_EX_IM  <= 0;
        end
        else if (Flush) begin
            ID_EX_PC  <= 0;
            ID_EX_RS1 <= 0;
            ID_EX_RS2 <= 0;
            ID_EX_IMM <= 0;
            ID_EX_IM  <= 32'h0000_0013;   // Canonical NOP
        end
        else begin
            ID_EX_PC  <= PC_in;
            ID_EX_RS1 <= Rs1_in;
            ID_EX_RS2 <= Rs2_in;
            ID_EX_IMM <= Imm_in;
            ID_EX_IM  <= IM_in;
        end
   end

   assign PC_out  = ID_EX_PC;
   assign Rs1_out = ID_EX_RS1;
   assign Rs2_out = ID_EX_RS2;
   assign Imm_out = ID_EX_IMM;
   assign IM_out  = ID_EX_IM;

endmodule


module pipe_EX_MEM #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
    )(
       input Clk, Rst, Flush,

       input [ADDR_WIDTH-1:0] PC_in,
       input [DATA_WIDTH-1:0] Rs2_in,
       input [DATA_WIDTH-1:0] ALU_in,
       input [DATA_WIDTH-1:0] IM_in,

       output [ADDR_WIDTH-1:0] PC_out,
       output [DATA_WIDTH-1:0] Rs2_out,
       output [DATA_WIDTH-1:0] ALU_out,
       output [DATA_WIDTH-1:0] IM_out
       );

   reg [ADDR_WIDTH-1:0] EX_MEM_PC;
   reg [DATA_WIDTH-1:0] EX_MEM_RS2;
   reg [DATA_WIDTH-1:0] EX_MEM_ALU;
   reg [DATA_WIDTH-1:0] EX_MEM_IM;

   always @(posedge Clk) begin
        if (Rst) begin
            EX_MEM_PC  <= 0;
            EX_MEM_RS2 <= 0;
            EX_MEM_ALU <= 0;
            EX_MEM_IM  <= 0;
        end
        else if (Flush) begin
            EX_MEM_PC  <= 0;
            EX_MEM_RS2 <= 0;
            EX_MEM_ALU <= 0;
            EX_MEM_IM  <= 32'h0000_0013;   // Canonical NOP
        end
        else begin
            EX_MEM_PC  <= PC_in;
            EX_MEM_RS2 <= Rs2_in;
            EX_MEM_ALU <= ALU_in;
            EX_MEM_IM  <= IM_in;
        end
   end

   assign PC_out  = EX_MEM_PC;
   assign Rs2_out = EX_MEM_RS2;
   assign ALU_out = EX_MEM_ALU;
   assign IM_out  = EX_MEM_IM;

endmodule


module pipe_MEM_WB #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
    )(
       input Clk, Rst, Flush,

       input [ADDR_WIDTH-1:0] PC_in,
       input [DATA_WIDTH-1:0] ALU_in,
       input [DATA_WIDTH-1:0] DM_in,
       input [DATA_WIDTH-1:0] IM_in,

       output [ADDR_WIDTH-1:0] PC_out,
       output [DATA_WIDTH-1:0] ALU_out,
       output [DATA_WIDTH-1:0] DM_out,
       output [DATA_WIDTH-1:0] IM_out
       );

   reg [ADDR_WIDTH-1:0] MEM_WB_PC;
   reg [DATA_WIDTH-1:0] MEM_WB_DM;
   reg [DATA_WIDTH-1:0] MEM_WB_ALU;
   reg [DATA_WIDTH-1:0] MEM_WB_IM;

   always @(posedge Clk) begin
        if (Rst) begin
            MEM_WB_PC  <= 0;
            MEM_WB_DM  <= 0;
            MEM_WB_ALU <= 0;
            MEM_WB_IM  <= 0;
        end
        else if (Flush) begin
            MEM_WB_PC  <= 0;
            MEM_WB_DM  <= 0;
            MEM_WB_ALU <= 0;
            MEM_WB_IM  <= 32'h0000_0013;   // Canonical NOP
        end
        else begin
            MEM_WB_PC  <= PC_in;
            MEM_WB_DM  <= DM_in;
            MEM_WB_ALU <= ALU_in;
            MEM_WB_IM  <= IM_in;
        end
   end

   assign PC_out  = MEM_WB_PC;
   assign DM_out  = MEM_WB_DM;
   assign ALU_out = MEM_WB_ALU;
   assign IM_out  = MEM_WB_IM;

endmodule