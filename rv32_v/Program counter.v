module PCBlock#(
   parameter DATA_WIDTH = 8
    )(
    input SelAdderPC,SelDataInPC,
    input Clk,Rst,PC_WEn,
    input [DATA_WIDTH-1:0] Immediate,
    input [DATA_WIDTH-1:0] MainALUData,
    input [DATA_WIDTH-1:0] BranchPC,
    output [DATA_WIDTH-1:0] PCnext,
    output [DATA_WIDTH-1:0] AddrOutPC
    );
    
    wire [DATA_WIDTH-1:0] temp_adder_0,temp_adder_1;
    wire [DATA_WIDTH-1:0] temp_mux1_mux2;
    wire [DATA_WIDTH-1:0] temp_mux2_pc;
    
    mux2to1 #(.DATA_WIDTH(DATA_WIDTH)) M0
             (.DataIn0(temp_adder_0),.DataIn1(temp_adder_1),
              .Sel(SelAdderPC),.DataOut(temp_mux1_mux2));
                 
    PCAdder  #(.DATA_WIDTH(DATA_WIDTH)) ADDImm
              (.DataIn0(Immediate),.DataIn1(BranchPC),
               .AddrOutPC(temp_adder_1));
    
    PCAdder  #(.DATA_WIDTH(DATA_WIDTH)) ADD4
              (.DataIn0(8'b0000_0100),.DataIn1(AddrOutPC),
               .AddrOutPC(temp_adder_0));
    
    assign PCnext = temp_adder_0;
    
    mux2to1 #(.DATA_WIDTH(DATA_WIDTH)) M1
             (.DataIn0(temp_mux1_mux2),.DataIn1(MainALUData),
              .Sel(SelDataInPC),.DataOut(temp_mux2_pc));
     
    ProgCounter #(.DATA_WIDTH(DATA_WIDTH)) PC
                  (.DataInPC(temp_mux2_pc),
                    .Clk(Clk),.Rst(Rst),.WEn(PC_WEn),
                    .AddrOutPC(AddrOutPC));         
    
endmodule

module PCAdder#(
    parameter DATA_WIDTH = 8 
    )(input [DATA_WIDTH-1:0] DataIn0,
      input [DATA_WIDTH-1:0] DataIn1,
      output [DATA_WIDTH-1:0] AddrOutPC
      );
      
    assign AddrOutPC = DataIn0 + DataIn1;
     
endmodule


module ProgCounter#(
    parameter DATA_WIDTH = 8
    )(input [DATA_WIDTH-1:0] DataInPC,
      input Clk,Rst,WEn,
      output [DATA_WIDTH-1:0] AddrOutPC
      );
      
      reg [DATA_WIDTH-1:0] mem;
      
      always @ (posedge Clk)
        if (Rst) begin
            mem <= 8'b0;
        end
        else if (WEn) begin
            mem <= DataInPC;
        end
     
     assign AddrOutPC = mem;
     
endmodule

