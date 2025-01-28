module  IF_ID
(
    input   wire            sys_clk  ,
    input   wire            sys_start,
    input   wire    [31:0]  pc_i     ,
    input   wire    [31:0]  instr_i  ,
    input   wire            hazard_i ,
    input   wire            flush_i  ,
    input   wire            isdiv_i  ,
/*     input   wire    [11:0]  pcIm_i   ,
    
    output  reg     [11:0]  pcIm_o   , */
    output  reg     [31:0]  pc_o     ,
    output  reg     [31:0]  instr_o  ,
    output  reg             isdiv_o  
);

always@(posedge sys_clk)
    begin
        if(sys_start == 1'b0)
            begin
                pc_o    <= 32'b0;
                instr_o <= 32'b0;
                isdiv_o <= 1'b0;
                // pcIm_o  <= 12'b0;
            end
        else if(flush_i)
            begin
                pc_o    <= pc_i;
                instr_o <= 32'b0;
                isdiv_o <= isdiv_i;
                // pcIm_o  <= 12'b0;
            end
        else if(hazard_i)
            begin
                pc_o    <= pc_i;
                instr_o <= instr_o;
                isdiv_o <= isdiv_i;
                // pcIm_o  <= pcIm_i;
            end
        else
            begin
                pc_o <= pc_i;
                instr_o <= instr_i;
                isdiv_o <= isdiv_i;
                // pcIm_o <= pcIm_i;
            end
    end
endmodule