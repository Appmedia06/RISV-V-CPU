// `timescale 1ns / 1ps

`include "cpu_define.v"

/* Instruction Memory */
module  instruction_memory
(
    input   wire                  sys_clk  ,
    input   wire                  sys_reset,    
    input   wire    [31:0]        addr_i   ,
    // input   wire    [7:0 ]        instr_i  ,
    
    output  wire    [31:0]        instr_o  
);

integer i; // for loop

/* 
    Instruction Memory(32x64):
        數據位寬: 32bits
        索引大小: 64
*/
reg     [`INSTR_MEM_BW]    instr_memory  [0: `INSTR_MEM_NUM - 1];

initial 
    begin
        $readmemh("../../program/demo/demo.inst", instr_memory);
    end 

/*
    quad         : 
    instr_read   : 
    address_read :
    flag         : 標示初始化狀態
    counter      : 
    instr_wr_addr: 
*/
/* reg     [1:0       ]    quad, quad_d1;
reg     [7:0       ]    instr_read;
reg     [5:0       ]    address_read;
reg                     flag, flag_next;
reg     [1:0       ]    counter, counter_next;
reg     [5:0       ]    instr_wr_addr, instr_wr_addr_next;  */


assign instr_o = instr_memory[addr_i >> 2];

/* always@(*)
    begin
        // Start Instruction 
        if(instr_i == `INSTR_START) 
            flag_next = 1'b1;
        // End Instruction 
        else if(instr_i == `INSTR_END && address_read > 6'd63)
            flag_next = 1'b0;
                
        else 
            flag_next = flag;
            
        if(flag)
            counter_next =  counter + 2'd1;
        else
            counter_next = counter;
        
        if(counter == 2'b11)
            instr_wr_addr_next = instr_wr_addr + 6'd1;
        else   
            instr_wr_addr_next = instr_wr_addr;
    end 


always@(posedge sys_clk or posedge sys_reset)
    begin
        if(sys_reset)
            begin
                for(i = 0; i <  `INSTR_MEM_NUM - 1; i = i + 1) // 63?
                    begin
                        instr_memory[i] <= 0;
                    end
                counter         <=    0;
                quad            <=    0;
                instr_read      <=    0;
                flag            <=    0;
                address_read    <=    0;
                instr_wr_addr   <=    0;
            end
        else
            begin
                flag            <=    flag_next;
                counter         <=    counter_next;
                quad            <=    (2'b11 - counter);
                quad_d1         <=    quad;
                instr_wr_addr   <=    instr_wr_addr_next;
                address_read    <=    instr_wr_addr;
                instr_read      <=    instr_i;
                
                if(flag)
                    begin
                        case(quad)
                        2'b00   : instr_memory[address_read][7:0]   <= (instr_read == 8'b1111_1111 && address_read > 6'd63) ? 0 : instr_read;
                        2'b01   : instr_memory[address_read][15:8]  <= (instr_read == 8'b1111_1111 && address_read > 6'd63) ? 0 : instr_read;
                        2'b10   : instr_memory[address_read][23:16] <= (instr_read == 8'b1111_1111 && address_read > 6'd63) ? 0 : instr_read;
                        2'b11   : instr_memory[address_read][31:24] <= (instr_read == 8'b1111_1111 && address_read > 6'd63) ? 0 : instr_read;
                        default : instr_memory[address_read][7:0]   <= (instr_read == 8'b1111_1111 && address_read > 6'd63) ? 0 : instr_read;
                        endcase
                    end
            end
    end  */

endmodule