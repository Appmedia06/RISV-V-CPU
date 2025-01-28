`include "cpu_define.v"

module  data_memory
(
    input   wire            sys_clk   ,
    input   wire            sys_reset ,
    input   wire    [10:0]  RD_addr_i ,
    input   wire    [31:0]  addr_i    ,
    input   wire    [31:0]  data_i    ,
    input   wire    [2:0 ]  funct3_i  ,
    input   wire            MemRead_i ,
    input   wire            MemWrite_i,
    
    output  reg     [31:0]  data_o    
);

/* 
    Data Memory(8x32):
        數據位寬: 8bits
        索引大小: 64
*/
reg     [`DATA_MEM_BW]    data_memory  [0: `DATA_MEM_NUM - 1];

parameter mem_offset = 11'h400; // data memory start address

wire    [31:0]  op;
wire    [31:0]  virtual_addr;
integer         i ; // for loop
wire    [7:0]   data_M_0;
wire    [7:0]   data_M_1;
wire    [7:0]   data_M_2;
wire    [7:0]   data_M_3;

wire    [7:0]   data_out_0;
wire    [7:0]   data_out_1;
wire    [7:0]   data_out_2;
wire    [7:0]   data_out_3;



assign virtual_addr = (MemRead_i || MemWrite_i) ? (addr_i - 11'h400) : 32'b0;

/* assign  op = {data_memory[virtual_addr + 3], data_memory[virtual_addr + 2], data_memory[virtual_addr + 1], data_memory[virtual_addr]};

assign  data_mem_o = {data_memory[RD_addr_i + 3], data_memory[RD_addr_i + 2], data_memory[RD_addr_i + 1], data_memory[RD_addr_i]}; */

assign  data_M_0 = data_memory[virtual_addr];
assign  data_M_1 = data_memory[virtual_addr + 1];
assign  data_M_2 = data_memory[virtual_addr + 2];
assign  data_M_3 = data_memory[virtual_addr + 3];

assign  data_out_0 = data_memory[RD_addr_i];
assign  data_out_1 = data_memory[RD_addr_i + 1];
assign  data_out_2 = data_memory[RD_addr_i + 2];
assign  data_out_3 = data_memory[RD_addr_i + 3];



always@(*)
    begin
        if (MemRead_i)
            begin
                case(funct3_i)
                
                // LB
                // 3'b000: data_o = {{24{op[7]}}, op[7:0]};
                3'b000: data_o = {{24{data_M_0[7]}}, data_M_0};
                // LH
                // 3'b001: data_o = {{16{op[15]}}, op[15:0]};
                3'b001: data_o = {{16{data_M_1[7]}}, data_M_1, data_M_0};
                // LW
                // 3'b010: data_o = op;
                3'b010: data_o = {data_M_3, data_M_2, data_M_1, data_M_0};
                // LBU
                3'b100: data_o = {24'b0, data_M_0};
                // LHU
                3'b101: data_o = {16'b0, data_M_1, data_M_0};
                
                default: data_o = 32'b0;
               
                endcase
            end
        else
            data_o = 32'b0;
    end
    
always@(posedge sys_clk or posedge sys_reset)
    begin   
        if(sys_reset)
            begin
                for(i = 0; i < `DATA_MEM_NUM; i = i + 1)
                    data_memory[i] <= 0;
            end
            
        else if(MemWrite_i)
            begin
                case(funct3_i)
                
                3'b000: // SB
                    begin
                        data_memory[virtual_addr    ] <= data_i[7:0  ];
                    end
                    
                3'b001: // SH
                    begin
                        data_memory[virtual_addr + 1] <= data_i[15:8 ];
                        data_memory[virtual_addr    ] <= data_i[7:0  ];
                    end
                
                3'b010: // SW
                    begin
                        data_memory[virtual_addr + 3] <= data_i[31:24];
                        data_memory[virtual_addr + 2] <= data_i[23:16];
                        data_memory[virtual_addr + 1] <= data_i[15:8 ];
                        data_memory[virtual_addr    ] <= data_i[7:0  ];
                    end
                default: data_memory[virtual_addr    ] <= data_i[7:0  ];
                endcase
            end
    end

/* always@(posedge sys_clk or posedge sys_reset)
    begin   
        if(sys_reset)
            begin
                for(i = 0; i < `DATA_MEM_NUM; i = i + 1)
                    data_memory[i] <= 0;
            end
    end */

endmodule
