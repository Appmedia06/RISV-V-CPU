`include "cpu_define.v"

/* Program Counter */
module  pc
(
    input   wire            sys_clk    ,
    input   wire            sys_start  ,
    input   wire    [31:0]  pc_i       ,
    input   wire            hazardPC_i ,
                        
    output  reg     [31:0]  pc_o       
);

reg     flag, flag_next;


always@(*)
    begin
        if(pc_i == `INSTR_MEM_ADDR_MAX)
            flag_next = 1'b1;
        else
            flag_next = flag;
    end
    
always@(posedge sys_clk or negedge sys_start)
    if(sys_start == 1'b0)
        begin
            pc_o <= 32'd0;
            flag <= 0;
        end
    else
        begin
            flag <= flag_next;
            if(sys_start & (!hazardPC_i))
                pc_o <= (flag) ? `INSTR_MEM_ADDR_MAX : pc_i;
            else
                pc_o <= pc_o;
        end
        
        
endmodule