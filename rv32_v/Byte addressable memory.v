module ByteAdrRAM #(

    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8,
    parameter BYTE = 2'b00,
    parameter HALF_WORD = 2'b01,
    parameter WORD = 2'b10
    )(
    input [DATA_WIDTH-1:0] DataIn,
    input Clk, WEn,
    input [1:0] WDataType,RDataType,
    input [ADDR_WIDTH-1:0] WAddr, RAddr,
    output [DATA_WIDTH-1:0] DataOut
    );
    // 000000_00   000000_01   000000_10   000000_11
    // 000001_00   000001_01   000001_10   000001_11
    // 000010_00   000010_01   000010_10   000010_11
    // 000011_00   000011_01   000011_10   000011_11
    // 000100_00   000100_01   000100_10   000100_11
    // 0  0  0  1  0  0  1  0 
    // 7  6  5  4  3  2  1  0
    
    // WHAT HAPPENS IF HALF_WORD AND WORD DEMAND END ADDRESS? i.e. 
    // WHAT DO TO IF WORD TYPE DEMANDS CONTENTS AT ADDR 1111_1111? 
    // - As of now I leave this responsibility to the programmer.
    
    // Haven't included sign-extension in the memory itself.
    wire [DATA_WIDTH-1:0] temp_route_cell; // Wires b/w write router and RAM cells
    wire [DATA_WIDTH-1:0] temp_cell_out;   // Wires b/w RAM cells and read router
    wire [3:0] temp_cell_wen;              // WEn signal from input port goes to write router
    wire [5:0] temp_waddr [0:3];           // Addresses passed by Write router to RAM cells
    wire [5:0] temp_raddr [0:3];           // Addresses passed by Read router to RAM cells
    
    WDataRouter WDR (.DataIn(DataIn),.WDataType(WDataType),
                     .WEn(WEn),.WAddr(WAddr),.DataOut(temp_route_cell),.CellWEn(temp_cell_wen),
                     .WAddr0(temp_waddr[0]),.WAddr1(temp_waddr[1]),
                     .WAddr2(temp_waddr[2]),.WAddr3(temp_waddr[3]));
    
    ByteRAM RAM0  (.DataIn(temp_route_cell[7:0]),.Clk(Clk),.WEn(temp_cell_wen[0]),
                   .WAddr(temp_waddr[0]),.RAddr(temp_raddr[0]),.DataOut(temp_cell_out[7:0]));
                   
    ByteRAM RAM1  (.DataIn(temp_route_cell[15:8]),.Clk(Clk),.WEn(temp_cell_wen[1]),
                   .WAddr(temp_waddr[1]),.RAddr(temp_raddr[1]),.DataOut(temp_cell_out[15:8]));
                   
    ByteRAM RAM2  (.DataIn(temp_route_cell[23:16]),.Clk(Clk),.WEn(temp_cell_wen[2]),
                   .WAddr(temp_waddr[2]),.RAddr(temp_raddr[2]),.DataOut(temp_cell_out[23:16]));
                   
    ByteRAM RAM3  (.DataIn(temp_route_cell[31:24]),.Clk(Clk),.WEn(temp_cell_wen[3]),
                   .WAddr(temp_waddr[3]),.RAddr(temp_raddr[3]),.DataOut(temp_cell_out[31:24]));
                   
    RDataRouter RDR (.DataIn0(temp_cell_out[7:0]),.DataIn1(temp_cell_out[15:8]),
                     .DataIn2(temp_cell_out[23:16]),.DataIn3(temp_cell_out[31:24]),
                     .RDataType(RDataType),.RAddr(RAddr),.DataOut(DataOut),
                     .RAddr0(temp_raddr[0]),.RAddr1(temp_raddr[1]),
                     .RAddr2(temp_raddr[2]),.RAddr3(temp_raddr[3]));

endmodule

module WDataRouter #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8,
    parameter BYTE = 2'b00,
    parameter HALF_WORD = 2'b01,
    parameter WORD = 2'b10
    )(
    input [DATA_WIDTH-1:0] DataIn,
    input [1:0] WDataType,
    input WEn,
    input [ADDR_WIDTH-1:0] WAddr,
    output reg [DATA_WIDTH-1:0] DataOut,
    output reg [3:0] CellWEn,
    output reg [5:0] WAddr0,WAddr1,WAddr2,WAddr3
    );
          
    // DATAOUT --> [CELL3,CELL2,CELL1,CELL0]      
     
          
    always @ (*) begin
    WAddr0 = WAddr[7:2];WAddr1 = WAddr[7:2];
    WAddr2 = WAddr[7:2];WAddr3 = WAddr[7:2];

    if (WEn) begin
        case (WDataType)
            BYTE : case (WAddr[1:0])  //  DataIn = 32'h0000_00XX
                            2'b00 : begin DataOut = {8'b0,8'b0,8'b0,DataIn[0+:8]}; CellWEn = 4'b0001; end
                            2'b01 : begin DataOut = {8'b0,8'b0,DataIn[0+:8],8'b0}; CellWEn = 4'b0010; end
                            2'b10 : begin DataOut = {8'b0,DataIn[0+:8],8'b0,8'b0}; CellWEn = 4'b0100; end
                            2'b11 : begin DataOut = {DataIn[0+:8],8'b0,8'b0,8'b0}; CellWEn = 4'b1000; end
                            default : begin DataOut = 32'b0; CellWEn = 4'b0000; end
                   endcase
        HALF_WORD : case (WAddr[1:0]) //  DataIn = 32'h0000_XXXX
                            2'b00 : begin DataOut = {8'b0,8'b0,DataIn[8+:8],DataIn[0+:8]}; CellWEn = 4'b0011; end
                            2'b01 : begin DataOut = {8'b0,DataIn[8+:8],DataIn[0+:8],8'b0}; CellWEn = 4'b0110; end
                            2'b10 : begin DataOut = {DataIn[8+:8],DataIn[0+:8],8'b0,8'b0}; CellWEn = 4'b1100; end
                            // Below is for wrap around in cell crossing case
                            2'b11 : begin DataOut = {DataIn[0+:8],8'b0,8'b0,DataIn[8+:8]}; 
                                                     WAddr0 = WAddr0 + 1;   CellWEn = 4'b1001; end
                                                     
                            default : begin DataOut = 32'b0; CellWEn = 4'b0000; end
                   endcase
            WORD : case (WAddr[1:0])
                            2'b00 : begin DataOut = {DataIn[24+:8],DataIn[16+:8],
                                                     DataIn[8+:8],DataIn[0+:8]}; CellWEn = 4'b1111; end
                                                      
                            2'b01 : begin DataOut = {DataIn[16+:8],DataIn[8+:8],
                                                     DataIn[0+:8],DataIn[24+:8]}; 
                                                     WAddr0 = WAddr0 + 1; CellWEn = 4'b1111; end
                                                     
                            2'b10 : begin DataOut = {DataIn[8+:8],DataIn[0+:8],
                                                     DataIn[24+:8],DataIn[16+:8]}; 
                                                     WAddr0 = WAddr0 + 1;
                                                     WAddr1 = WAddr1 + 1;CellWEn = 4'b1111; end
                                                     
                            2'b11 : begin DataOut = {DataIn[0+:8],DataIn[24+:8],
                                                     DataIn[16+:8],DataIn[8+:8]}; 
                                                     WAddr0 = WAddr0 + 1;
                                                     WAddr1 = WAddr1 + 1;
                                                     WAddr2 = WAddr2 + 1;CellWEn = 4'b1111; end
                            default : begin DataOut = 32'b0; CellWEn = 4'b0000; end
                   endcase
            default : begin DataOut = 32'b0; CellWEn = 4'b0000; end
       endcase
       end
       
       else begin
             DataOut = 32'b0; CellWEn = 4'b0000; 
            end
   end
   
endmodule

module RDataRouter #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8,
    parameter BYTE = 2'b00,
    parameter HALF_WORD = 2'b01,
    parameter WORD = 2'b10
    )(
    input [ADDR_WIDTH-1:0] DataIn0,
    input [ADDR_WIDTH-1:0] DataIn1,
    input [ADDR_WIDTH-1:0] DataIn2,
    input [ADDR_WIDTH-1:0] DataIn3,
    input [1:0] RDataType,
    input [ADDR_WIDTH-1:0] RAddr,
    output reg [DATA_WIDTH-1:0] DataOut,
    output reg [5:0] RAddr0,RAddr1,RAddr2,RAddr3
    );
    

    always @ (*) begin
    RAddr0 = RAddr[7:2];RAddr1 = RAddr[7:2];
    RAddr2 = RAddr[7:2];RAddr3 = RAddr[7:2];
        case (RDataType)
            BYTE : case (RAddr[1:0])
                            2'b00 : DataOut = {8'b0,8'b0,8'b0,DataIn0};
                            2'b01 : DataOut = {8'b0,8'b0,8'b0,DataIn1};
                            2'b10 : DataOut = {8'b0,8'b0,8'b0,DataIn2};
                            2'b11 : DataOut = {8'b0,8'b0,8'b0,DataIn3};
                            default : DataOut = 32'b0;
                   endcase
        HALF_WORD : case (RAddr[1:0])
                            2'b00 : DataOut = {8'b0,8'b0,DataIn1,DataIn0};
                            2'b01 : DataOut = {8'b0,8'b0,DataIn2,DataIn1};
                            2'b10 : DataOut = {8'b0,8'b0,DataIn3,DataIn2};
                            2'b11 : begin DataOut = {8'b0,8'b0,DataIn0,DataIn3}; 
                                          RAddr0 = RAddr0 + 1; end
                                            
                            default : DataOut = 32'b0;
                   endcase
            WORD : case (RAddr[1:0])
                            2'b00 : DataOut ={DataIn3,DataIn2,DataIn1,DataIn0};
                            2'b01 : begin DataOut ={DataIn0,DataIn3,DataIn2,DataIn1};
                                    RAddr0 = RAddr0 + 1; end
                                    
                            2'b10 : begin DataOut ={DataIn1,DataIn0,DataIn3,DataIn2};
                                    RAddr0 = RAddr0 + 1;
                                    RAddr1 = RAddr1 + 1; end
                            2'b11 : begin DataOut ={DataIn2,DataIn1,DataIn0,DataIn3};
                                    RAddr0 = RAddr0 + 1;
                                    RAddr1 = RAddr1 + 1;
                                    RAddr2 = RAddr2 + 1; end
                            default : DataOut = 32'b0;
                   endcase
            default : DataOut = 32'b0;
       endcase
   end
   
endmodule

module ByteRAM #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 6
    )(
    input [DATA_WIDTH-1:0] DataIn,
    input Clk, WEn, 
    input [ADDR_WIDTH-1:0] WAddr, RAddr,
    output [DATA_WIDTH-1:0] DataOut
    );
    
    reg [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];
    always @ (posedge Clk)
        begin
            if (WEn) begin
                mem[WAddr] <= DataIn;
                end
        end
    
    assign DataOut = mem[RAddr];     
       
            
endmodule
